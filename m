From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: macvlan on top mlx4 fails
Date: Fri, 29 Jan 2010 15:31:11 +0100
Message-ID: <4B62F12F.9020302@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:55386 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755683Ab0A2ObP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2010 09:31:15 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id o0TEVEqC031385
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 14:31:14 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0TEVDcf1446138
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 15:31:13 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o0TEVD8h030576
	for <netdev@vger.kernel.org>; Fri, 29 Jan 2010 15:31:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I am trying to have a macvlan on top of an ethernet driver infiniband 
emulation communicating with the macvlan on anoher host with the same 
configuration. But I am not able to ping them through the ip address 
assigned to each macvlan.

On the host1 (s1):

s1:~> ifconfig
eth1      Link encap:Ethernet  HWaddr 00:1A:64:44:B5:FB
           inet addr:9.114.244.95  Bcast:9.114.247.255  Mask:255.255.248.0
           inet6 addr: fe80::21a:64ff:fe44:b5fb/64 Scope:Link
           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
           RX packets:5355123 errors:0 dropped:0 overruns:0 frame:0
           TX packets:2193023 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:791518554 (754.8 Mb)  TX bytes:18432872954 (17578.9 Mb)

ib0       Link encap:UNSPEC  HWaddr 
80-00-00-48-FE-80-00-00-00-00-00-00-00-00-00-00
           inet addr:192.168.0.95  Bcast:192.168.0.255  Mask:255.255.255.0
           inet6 addr: fe80::202:c903:1:1b1d/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:2044  Metric:1
           RX packets:306 errors:0 dropped:0 overruns:0 frame:0
           TX packets:272 errors:0 dropped:5 overruns:0 carrier:0
           collisions:0 txqueuelen:256
           RX bytes:27870 (27.2 Kb)  TX bytes:27150 (26.5 Kb)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:170697 errors:0 dropped:0 overruns:0 frame:0
           TX packets:170697 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:61678890 (58.8 Mb)  TX bytes:61678890 (58.8 Mb)

mc1       Link encap:Ethernet  HWaddr 86:D7:44:D4:DC:C0
           inet addr:1.2.3.5  Bcast:0.0.0.0  Mask:255.255.255.0
           inet6 addr: fe80::84d7:44ff:fed4:dcc0/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:11903 errors:0 dropped:0 overruns:0 frame:0
           TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:851808 (831.8 Kb)  TX bytes:468 (468.0 b)


s2:~ # ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
     link/ether 00:1a:64:44:b5:22 brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc 
pfifo_fast state UNKNOWN qlen 1000
     link/ether 00:1a:64:44:b5:23 brd ff:ff:ff:ff:ff:ff
4: ib0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 2044 qdisc pfifo_fast 
state UP qlen 256
     link/infiniband 
80:00:00:48:fe:80:00:00:00:00:00:41:00:02:c9:03:00:01:1e:bd brd 
00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
5: ib1: <BROADCAST,MULTICAST> mtu 2044 qdisc noop state DOWN qlen 256
     link/infiniband 
80:00:00:49:fe:80:00:00:00:00:00:00:00:02:c9:03:00:01:1e:be brd 
00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
49: mc1@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue 
state UNKNOWN
     link/ether be:7e:6e:dd:58:c0 brd ff:ff:ff:ff:ff:ff


On the host2 (s2):

s2:~ # ifconfig
eth1      Link encap:Ethernet  HWaddr 00:1A:64:44:B5:23
           inet addr:9.114.244.96  Bcast:9.114.247.255  Mask:255.255.248.0
           inet6 addr: fe80::21a:64ff:fe44:b523/64 Scope:Link
           UP BROADCAST RUNNING PROMISC MULTICAST  MTU:1500  Metric:1
           RX packets:967848 errors:0 dropped:0 overruns:0 frame:0
           TX packets:100977 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:1000
           RX bytes:1535677477 (1464.5 Mb)  TX bytes:61077758 (58.2 Mb)

ib0       Link encap:UNSPEC  HWaddr 
80-00-00-48-FE-80-00-00-00-00-00-00-00-00-00-00
           inet addr:192.168.0.96  Bcast:192.168.0.255  Mask:255.255.255.0
           inet6 addr: fe80::202:c903:1:1ebd/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:2044  Metric:1
           RX packets:58 errors:0 dropped:0 overruns:0 frame:0
           TX packets:34 errors:0 dropped:5 overruns:0 carrier:0
           collisions:0 txqueuelen:256
           RX bytes:7305 (7.1 Kb)  TX bytes:4145 (4.0 Kb)

lo        Link encap:Local Loopback
           inet addr:127.0.0.1  Mask:255.0.0.0
           inet6 addr: ::1/128 Scope:Host
           UP LOOPBACK RUNNING  MTU:16436  Metric:1
           RX packets:580 errors:0 dropped:0 overruns:0 frame:0
           TX packets:580 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:43888 (42.8 Kb)  TX bytes:43888 (42.8 Kb)

mc1       Link encap:Ethernet  HWaddr BE:7E:6E:DD:58:C0
           inet addr:1.2.3.4  Bcast:0.0.0.0  Mask:255.255.255.0
           inet6 addr: fe80::bc7e:6eff:fedd:58c0/64 Scope:Link
           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
           RX packets:12411 errors:0 dropped:0 overruns:0 frame:0
           TX packets:9 errors:0 dropped:0 overruns:0 carrier:0
           collisions:0 txqueuelen:0
           RX bytes:886732 (865.9 Kb)  TX bytes:594 (594.0 b)

s1:~ # ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
     link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN qlen 
1000
     link/ether 00:1a:64:44:b5:fa brd ff:ff:ff:ff:ff:ff
3: eth1: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc 
pfifo_fast state UNKNOWN qlen 1000
     link/ether 00:1a:64:44:b5:fb brd ff:ff:ff:ff:ff:ff
4: ib0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 2044 qdisc pfifo_fast 
state UP qlen 256
     link/infiniband 
80:00:00:48:fe:80:00:00:00:00:00:41:00:02:c9:03:00:01:1b:1d brd 
00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
5: ib1: <BROADCAST,MULTICAST> mtu 2044 qdisc noop state DOWN qlen 256
     link/infiniband 
80:00:00:49:fe:80:00:00:00:00:00:00:00:02:c9:03:00:01:1b:1e brd 
00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
85: mc1@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue 
state UNKNOWN
     link/ether 86:d7:44:d4:dc:c0 brd ff:ff:ff:ff:ff:ff



The ping result:

s2:~ # ping 1.2.3.5
PING 1.2.3.5 (1.2.3.5) 56(84) bytes of data.
 From 1.2.3.4: icmp_seq=2 Destination Host Unreachable
 From 1.2.3.4 icmp_seq=2 Destination Host Unreachable
 From 1.2.3.4 icmp_seq=3 Destination Host Unreachable
 From 1.2.3.4 icmp_seq=4 Destination Host Unreachable
^C
--- 1.2.3.5 ping statistics ---
5 packets transmitted, 0 received, +4 errors, 100% packet loss, time 4010ms
, pipe 3

The arp cache:

Address                  HWtype  HWaddress           Flags Mask 
    Iface
1.2.3.5                          (incomplete) 
    mc1


When doing a tcpdump on s2 host, I have arp who-as request:


09:14:20.764389 arp who-has 1.2.3.5 tell 1.2.3.4
09:14:20.764394 arp who-has 1.2.3.5 tell 1.2.3.4
09:14:20.764427 arp who-has 1.2.3.5 tell 1.2.3.4


But doing the same tcpdump on the s1 host I don't see there arp request.

The output of lscpi:

s2:~ # lspci
0000:00:01.0 RAID bus controller: IBM Obsidian chipset SCSI controller 
(rev 02)
0001:00:01.0 USB Controller: NEC Corporation USB (rev 43)
0001:00:01.1 USB Controller: NEC Corporation USB (rev 43)
0001:00:01.2 USB Controller: NEC Corporation USB 2.0 (rev 04)
0002:00:01.0 VGA compatible controller: ATI Technologies Inc ES1000 (rev 02)
0003:01:00.0 InfiniBand: Mellanox Technologies MT25418 [ConnectX IB DDR, 
PCIe 2.0 2.5GT/s] (rev a0)


I am a newbie on infiniband so I was wondering if I did something wrong 
or if this is unsupported.

Thanks in advance.
   -- Daniel

ps : I was not able to find the email of the mlx4 driver maintainer.
