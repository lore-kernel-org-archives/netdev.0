From: "Suresh Krishnan (QB/EMC)" <suresh.krishnan@ericsson.com>
Subject: Interface forgets IPv6 address
Date: Fri, 26 Sep 2003 18:00:11 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <7B2A7784F4B7F0409947481F3F3FEF830837B105@eammlex037.lmc.ericsson.se>
Reply-To: "Suresh Krishnan (QB/EMC)" <suresh.krishnan@ericsson.ca>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
  I am trying to bring an interface down temporarily and bring it back up. 
I have one IPv4 address and 1 IPv6 address (global scope) and the IPv6 
link local address. The problem I have is that, after I bring the 
interface back up, the IPv6 global scope address is lost from the interface 
configuration. Is this expected behaviour? 

Here is the sequence of commands to reproduce my problem 
(I have tried it on multiple kernel versions, multiple IPv6 stacks and 
having IPv6 as a module as well as compiled in the kernel ). 

Initial state
=============
[root@spock home]#uname -a
Linux spock 2.4.20-19.9 #1 Tue Jul 15 17:18:13 EDT 2003 i686 i686 i386 
GNU/Linux
[root@spock home]#ip address
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 brd 127.255.255.255 scope host lo
    inet6 ::1/128 scope host 
2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:08:74:cc:ef:ea brd ff:ff:ff:ff:ff:ff
    inet 142.133.72.18/26 brd 142.133.72.63 scope global eth0
    inet6 2001::1/64 scope global 
    inet6 fe80::208:74ff:fecc:efea/64 scope link 
3: sit0@NONE: <NOARP> mtu 1480 qdisc noop 
    link/sit 0.0.0.0 brd 0.0.0.0

Interface down state
====================
[root@spock home]#ifconfig eth0 down
[root@spock home]#ip address
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 brd 127.255.255.255 scope host lo
    inet6 ::1/128 scope host 
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:08:74:cc:ef:ea brd ff:ff:ff:ff:ff:ff
    inet 142.133.72.18/26 brd 142.133.72.63 scope global eth0
3: sit0@NONE: <NOARP> mtu 1480 qdisc noop 
    link/sit 0.0.0.0 brd 0.0.0.0

Interface back up
=================
[root@spock home]#ifconfig eth0 up 
[root@spock home]#ip a
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 brd 127.255.255.255 scope host lo
    inet6 ::1/128 scope host 
2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:08:74:cc:ef:ea brd ff:ff:ff:ff:ff:ff
    inet 142.133.72.18/26 brd 142.133.72.63 scope global eth0
    inet6 fe80::208:74ff:fecc:efea/64 scope link 
3: sit0@NONE: <NOARP> mtu 1480 qdisc noop 
    link/sit 0.0.0.0 brd 0.0.0.0

TIA
Suresh
