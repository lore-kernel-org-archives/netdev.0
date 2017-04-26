From: =?utf-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <ne-vlezay80@yandex.ru>
Subject: Low speed MPLS to virtio-net
Date: Wed, 26 Apr 2017 22:15:29 +0300
Message-ID: <428971493234129@web14g.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward20m.cmail.yandex.net ([5.255.216.151]:40299 "EHLO
        forward20m.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S966231AbdDZTXH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 15:23:07 -0400
Received: from mxback13g.mail.yandex.net (mxback13g.mail.yandex.net [IPv6:2a02:6b8:0:1472:2741:0:8b7:92])
        by forward20m.cmail.yandex.net (Yandex) with ESMTP id 34E2A21861
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 22:15:30 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Started MPLS on the branch - Everything was fine. When I tried to run MPLS on a real network of virtual machines, there were problems with the speed:
root@containers:~# iperf3 -c 10.194.10.2 -B 10.194.10.1 -Z       
Connecting to host 10.194.10.2, port 5201
[  4] local 10.194.10.1 port 49533 connected to 10.194.10.2 port 5201
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec  1018 KBytes  8.34 Mbits/sec  238   5.64 KBytes       
[  4]   1.00-2.00   sec  1.42 MBytes  11.9 Mbits/sec  373   1.41 KBytes       
[  4]   2.00-3.00   sec  1.43 MBytes  12.0 Mbits/sec  379   5.64 KBytes       
[  4]   3.00-4.00   sec  1.43 MBytes  12.0 Mbits/sec  376   5.64 KBytes       
[  4]   4.00-5.00   sec  1.41 MBytes  11.8 Mbits/sec  375   2.82 KBytes       
[  4]   5.00-6.00   sec  1.42 MBytes  11.9 Mbits/sec  376   2.82 KBytes       
[  4]   6.00-7.00   sec  1.42 MBytes  11.9 Mbits/sec  373   5.64 KBytes       
[  4]   7.00-8.00   sec  1.41 MBytes  11.8 Mbits/sec  372   5.64 KBytes       
[  4]   8.00-9.00   sec  1.42 MBytes  11.9 Mbits/sec  379   2.82 KBytes       
[  4]   9.00-10.00  sec  1.42 MBytes  11.9 Mbits/sec  373   5.64 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-10.00  sec  13.8 MBytes  11.5 Mbits/sec  3614             sender
[  4]   0.00-10.00  sec  13.6 MBytes  11.4 Mbits/sec                  receiver

iperf Done.
root@containers:~# 
Here are the settings:
test0:
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo:1: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 10.194.10.1  netmask 255.255.255.255
        loop  txqueuelen 1000  (Local Loopback)

test0p1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.194.1.50  netmask 255.255.255.0  broadcast 10.194.1.255
        inet6 fe80::b0a7:b1ff:fec1:3d5c  prefixlen 64  scopeid 0x20<link>
        ether b2:a7:b1:c1:3d:5c  txqueuelen 1000  (Ethernet)
        RX packets 19974  bytes 1410944 (1.3 MiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 3726844  bytes 5236310466 (4.8 GiB)
        TX errors 0  dropped 3604 overruns 0  carrier 0  collisions 0

test1:
lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        inet6 ::1  prefixlen 128  scopeid 0x10<host>
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo:1: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 10.194.10.2  netmask 255.255.255.255
        loop  txqueuelen 1000  (Local Loopback)

test1p1: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 10.194.1.51  netmask 255.255.255.0  broadcast 10.194.1.255
        inet6 fe80::5cc0:45ff:fe1a:9705  prefixlen 64  scopeid 0x20<link>
        ether 5e:c0:45:1a:97:05  txqueuelen 1000  (Ethernet)
        RX packets 2001923  bytes 2806406771 (2.6 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 19907  bytes 1485150 (1.4 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

Server configuration:
root@ne-vlezay80:~# ip -M r
100 via inet 10.194.1.50 dev vlan11 
101 via inet 10.194.1.51 dev vlan11 
root@ne-vlezay80:~# 
root@ne-vlezay80:~# ifconfig
eth0      Link encap:Ethernet  HWaddr 52:54:00:5d:81:90  
          inet addr:10.247.0.250  Bcast:10.247.0.255  Mask:255.255.255.0
          inet6 addr: fe80::5054:ff:fe5d:8190/64 Scope:Link
          inet6 addr: fd00:1002:1289:10::10/64 Scope:Global
          UP BROADCAST RUNNING MULTICAST  MTU:2500  Metric:1
          RX packets:7403 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4182 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:621871 (607.2 KiB)  TX bytes:445766 (435.3 KiB)

eth1      Link encap:Ethernet  HWaddr 52:54:00:0b:ff:2e  
          inet addr:192.168.122.1  Bcast:192.168.122.255  Mask:255.255.255.0
          inet6 addr: fd00:104:1::1/64 Scope:Global
          inet6 addr: fe80::5054:ff:fe0b:ff2e/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:2500  Metric:1
          RX packets:2204837 errors:0 dropped:5 overruns:0 frame:0
          TX packets:2083636 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:3073876412 (2.8 GiB)  TX bytes:2897017540 (2.6 GiB)

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:65536  Metric:1
          RX packets:75 errors:0 dropped:0 overruns:0 frame:0
          TX packets:75 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:6600 (6.4 KiB)  TX bytes:6600 (6.4 KiB)

servers   Link encap:Ethernet  HWaddr b2:c2:cf:9a:9c:00  
          UP RUNNING NOARP MASTER  MTU:65536  Metric:1
          RX packets:2259 errors:0 dropped:0 overruns:0 frame:0
          TX packets:4062 errors:0 dropped:219 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:220368 (215.2 KiB)  TX bytes:340283 (332.3 KiB)

vlan10    Link encap:Ethernet  HWaddr 52:54:00:0b:ff:2e  
          inet addr:10.194.0.1  Bcast:10.194.0.255  Mask:255.255.255.0
          inet6 addr: 2a01:d0:c353:180::1/64 Scope:Global
          inet6 addr: fe80::5054:ff:fe0b:ff2e/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:2500  Metric:1
          RX packets:2260 errors:0 dropped:0 overruns:0 frame:0
          TX packets:15 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:85868 (83.8 KiB)  TX bytes:1322 (1.2 KiB)

vlan11    Link encap:Ethernet  HWaddr 52:54:00:0b:ff:2e  
          inet addr:10.194.1.1  Bcast:10.194.1.255  Mask:255.255.255.0
          inet6 addr: fe80::5054:ff:fe0b:ff2e/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:2500  Metric:1
          RX packets:2201655 errors:0 dropped:58 overruns:0 frame:0
          TX packets:2083391 errors:0 dropped:119523 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:3034042872 (2.8 GiB)  TX bytes:2888672290 (2.6 GiB)
