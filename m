From: Fabio Uggeri <f.uggeri@iol.it>
Subject: TEQL with two ADSL connection
Date: Wed, 01 May 2002 10:54:59 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3CCFAD63.ACC70C8C@iol.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,
in my school I have:
- two Netopia router for ADSL (perform NAT),
- one linux box with 3 ethernet card

I want to make a load balancing on the two ADSL line.

I have configured the system as follow:

The LAN interface, of the two ADSL router, have address
(A) 192.168.0.254
(B) 192.168.2.254
The 3 ethernet card, on the linux box, have address:
-eth2   172.16.255.254, connected to a switch and operate with VLANs
-eth1   192.168.0.2, directly connected to the router (A)
-eth0   192.168.2.2, directly connected to the router (B)

The routing with router (A) or (B) work fine.

I want to do a load balancing using teql

I have configured the qdisc and teql as follow

#ip route del default
#tc qdisc add dev eth0 root teql0
#tc qdisc add dev eth1 root teql0
#ip addr del 192.168.0.2 dev eth1
#ip addr del 192.168.2.2 dev eth0

#ip address add 192.168.0.2/24 dev teql0
#ip address add 192.168.2.2/24 dev teql0
#ip link set teql0 up
#ip route add default/0 dev teql0


The rp filter of eth0 and eth1 are turned off by default.
After I have done some ping and traceroute but I haven't answers
then I have done

#ip neigh ls
172.16.240.1 dev eth2 lladdr 00:d0:b7:49:6f:09 nud stale
172.16.1.3 dev vlan0017 lladdr 00:10:a7:0f:01:23 nud stale
172.16.4.4 dev vlan0017 lladdr 00:10:a7:12:4c:01 nud stale
172.16.97.3 dev vlan0014 lladdr 00:40:f4:34:b5:69 nud reachable

#tc -s qdisc ls
qdisc teql0 8001: dev eth0
 Sent 829337 bytes 5807 pkts (dropped 0, overlimits 0)

 qdisc teql0 8002: dev eth1
 Sent 4536 bytes 108 pkts (dropped 0, overlimits 0)

# ip -s link ls
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    RX: bytes  packets  errors  dropped overrun mcast
    420        6        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    420        6        0       0       0       0

2: teql0: <BROADCAST,NOARP,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/[65535]
    RX: bytes  packets  errors  dropped overrun mcast
    0          0        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    0          0        161    161     0       0

**** there are OUTPUT ERRORS *****

3: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc teql0 qlen 100
    link/ether 00:00:21:e7:9f:93 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    6445168    9286     0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    1233331    8555     0       0       0       1
4: eth1: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc teql0 qlen 100
    link/ether 00:00:21:e3:d1:78 brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    354        4        0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    6834       112      0       0       0       0
5: eth2: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:a0:d2:12:8f:bb brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    1817579    12549    0       0       0       0
    TX: bytes  packets  errors  dropped carrier collsns
    6473156    9749     0       0       0       0
6: vlan0005: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue
    link/ether 00:a0:d2:12:8f:bb brd ff:ff:ff:ff:ff:ff
    RX: bytes  packets  errors  dropped overrun mcast
    13487      188      0       0       0       37
    TX: bytes  packets  errors  dropped carrier collsns
    424811     287      0       0       0       0
   ......
   .......

#ip route list
192.168.2.0/24 dev teql0  proto kernel  scope link  src 192.168.2.2
192.168.0.0/24 dev teql0  proto kernel  scope link  src 192.168.0.2
172.16.240.0/20 dev eth2  proto kernel  scope link  src 172.16.255.254
172.16.128.0/20 dev vlan0025  proto kernel  scope link  src
172.16.143.254
172.16.80.0/20 dev vlan0013  proto kernel  scope link  src 172.16.95.254

........
.......
127.0.0.0/8 dev lo  scope link
default dev teql0  scope link




 Any suggestion will be appreciated

Tank you
Fabio Uggeri
I.T.I.S. "G. Galilei"
Livorno - ITALY
