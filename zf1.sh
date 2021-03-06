#!/bin/bash
#1、一般情况下，Linux最新发行版会默认安装nftables，使用以下命令关闭firewalld、关闭selinux、开启内核端口转发、安装nftables；
setHaProxy1(){
service firewalld stop
systemctl disable firewalld
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config  
sed -n '/^net.ipv4.ip_forward=1/'p /etc/sysctl.conf | grep -q "net.ipv4.ip_forward=1"
echo 1 > /proc/sys/net/ipv4/ip_forward
if [ $? -ne 0 ]; then
    echo -e "net.ipv4.ip_forward=1" >> /etc/sysctl.conf && sysctl -p
fi
apt install -y  nftables
}
#2、下载可执行文件并赋予执行权限；
setHaProxy2(){
wget -O /usr/local/bin/nat https://getzhuji.com/wp-content/uploads/sh/dnat
chmod +x /usr/local/bin/nat
}
#3、创建systemd服务；
setHaProxy3(){
cat > /lib/systemd/system/nat.service <<EOF
[Unit] 
Description=dnat-service 
After=network-online.target 
Wants=network-online.target 
 
[Service] 
ExecStart=/usr/local/bin/nat /etc/nat.conf 
LimitNOFILE=100000 
Restart=always 
RestartSec=60 
 
[Install] 
WantedBy=multi-user.target 
EOF
}
#4、设置为开机启动，并启动该服务；
setHaProxy4(){
systemctl daemon-reload
systemctl enable nat
systemctl start nat
}
#5、生成配置文件，也可以使用 vi /etc/nat.conf 命令添加删除修改转发规则；
setHaProxy5(){
cat > /etc/nat.conf <<EOF 
SINGLE,11168,5555,asia2.ethermine.org
EOF
}
#注释：

#每行代表1个规则，行内以英文逗号分隔为4段
