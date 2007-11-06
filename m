From: Moni Shoua <monis@voltaire.com>
Subject: Re: problems with ib-bonding of 2.6.24-rc1
Date: Tue, 06 Nov 2007 08:52:54 +0200
Message-ID: <47300F46.9000507@voltaire.com>
References: <472DF022.3000604@voltaire.com> <472EFB28.9090000@gmail.com> <20510.1194311154@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:14268 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754307AbXKFGxE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 01:53:04 -0500
In-Reply-To: <20510.1194311154@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Moni Shoua <monisonlists@gmail.com> wrote:
> 
>> Basically, what I see is that after a while commands like ifconfig or ip stucks.
>> I only use sysfs  to configure bonding (which also stucks after a while).
> 
> 	I've fooled with setting various things in bonding in the
> current linux-2.6 git kernel, and I'm not seeing the failure you
> describe.  Can you provide some step by step instructions, including the
> type of system, bonding mode, options, number and type of slaves, etc,
> to induce the failure?
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
Machine
-------------------
ARCH:	x86_64
OS:	Redhat EL Server 5

bonding
-------------------
mod. options:	none
mode:		1 (active-backup)
miimon:		100
slaves:		IP over InfiniBand

Below is a scenario that ends up with what I described

[root@linux root]# ifconfig -a
eth0      Link encap:Ethernet  HWaddr 00:04:23:B3:25:C4
          inet addr:172.30.3.234  Bcast:172.30.255.255  Mask:255.255.0.0
          inet6 addr: fe80::204:23ff:feb3:25c4/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:333219 errors:0 dropped:0 overruns:0 frame:0
          TX packets:130880 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:248023834 (236.5 MiB)  TX bytes:35230500 (33.5 MiB)
          Base address:0xdc00 Memory:fcea0000-fcec0000

eth1      Link encap:Ethernet  HWaddr 00:04:23:B3:25:C5
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)
          Base address:0xdc80 Memory:fcee0000-fcf00000

ib0       Link encap:InfiniBand  HWaddr 00:00:04:04:FE:80:00:00:00:00:00:00:00:00:00:00:00:00:00:00
          BROADCAST MULTICAST  MTU:2044  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:128
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

ib1       Link encap:InfiniBand  HWaddr 00:00:04:05:FE:80:00:00:00:00:00:00:00:00:00:00:00:00:00:00
          BROADCAST MULTICAST  MTU:2044  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:128
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:44 errors:0 dropped:0 overruns:0 frame:0
          TX packets:44 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:7145 (6.9 KiB)  TX bytes:7145 (6.9 KiB)

sit0      Link encap:IPv6-in-IPv4
          NOARP  MTU:1480  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 b)  TX bytes:0 (0.0 b)

[root@linux root]# modprobe bonding
[root@linux root]# echo 1 > /sys/class/net/bond0/bonding/mode
[root@linux root]# echo 100 > /sys/class/net/bond0/bonding/miimon
[root@linux root]# echo +ib0 > /sys/class/net/bond0/bonding/slaves
[root@linux root]# echo +ib1 > /sys/class/net/bond0/bonding/slaves
[root@linux root]# ifconfig bond0 192.168.3.234
[root@linux root]# ip a s
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast qlen 100
    link/ether 00:04:23:b3:25:c4 brd ff:ff:ff:ff:ff:ff
    inet 172.30.3.234/16 brd 172.30.255.255 scope global eth0
    inet6 fe80::204:23ff:feb3:25c4/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop qlen 1000
    link/ether 00:04:23:b3:25:c5 brd ff:ff:ff:ff:ff:ff
4: sit0: <NOARP> mtu 1480 qdisc noop
    link/sit 0.0.0.0 brd 0.0.0.0
5: ib0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 128
    link/infiniband 00:00:04:04:fe:80:00:00:00:00:00:00:00:08:f1:04:03:96:e8:a9 brd 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
6: ib1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 128
    link/infiniband 00:00:04:05:fe:80:00:00:00:00:00:00:00:08:f1:04:03:96:e8:aa brd 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
8: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc noqueue
    link/infiniband 00:00:04:04:fe:80:00:00:00:00:00:00:00:08:f1:04:03:96:e8:a9 brd 00:ff:ff:ff:ff:12:40:1b:ff:ff:00:00:00:00:00:00:ff:ff:ff:ff
    inet 192.168.3.234/24 brd 192.168.3.255 scope global bond0
    inet6 fe80::208:f104:396:e8a9/64 scope link
       valid_lft forever preferred_lft forever
[root@linux root]# ping -c 1 192.168.3.232
PING 192.168.3.232 (192.168.3.232) 56(84) bytes of data.
64 bytes from 192.168.3.232: icmp_seq=1 ttl=64 time=0.112 ms

--- 192.168.3.232 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.112/0.112/0.112/0.000 ms
[root@linux root]# ifconfig
bond0     Link encap:InfiniBand  HWaddr 00:00:04:04:FE:80:00:00:00:00:00:00:00:00:00:00:00:00:00:00
          inet addr:192.168.3.234  Bcast:192.168.3.255  Mask:255.255.255.0
          inet6 addr: fe80::208:f104:396:e8a9/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:53 errors:0 dropped:0 overruns:0 frame:0
          TX packets:23 errors:0 dropped:7 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:4172 (4.0 KiB)  TX bytes:4085 (3.9 KiB)

eth0      Link encap:Ethernet  HWaddr 00:04:23:B3:25:C4
          inet addr:172.30.3.234  Bcast:172.30.255.255  Mask:255.255.0.0
          inet6 addr: fe80::204:23ff:feb3:25c4/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:334158 errors:0 dropped:0 overruns:0 frame:0
          TX packets:131146 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:248115222 (236.6 MiB)  TX bytes:35272782 (33.6 MiB)
          Base address:0xdc00 Memory:fcea0000-fcec0000

ib0       Link encap:InfiniBand  HWaddr 00:00:04:04:FE:80:00:00:00:00:00:00:00:00:00:00:00:00:00:00
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:29 errors:0 dropped:0 overruns:0 frame:0
          TX packets:23 errors:0 dropped:7 overruns:0 carrier:0
          collisions:0 txqueuelen:128
          RX bytes:2284 (2.2 KiB)  TX bytes:4085 (3.9 KiB)

ib1       Link encap:InfiniBand  HWaddr 00:00:04:05:FE:80:00:00:00:00:00:00:00:00:00:00:00:00:00:00
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:24 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:128
          RX bytes:1888 (1.8 KiB)  TX bytes:0 (0.0 b)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:44 errors:0 dropped:0 overruns:0 frame:0
          TX packets:44 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:7145 (6.9 KiB)  TX bytes:7145 (6.9 KiB)

[root@linux root]# cat /sys/class/net/bond0/bonding/active_slave
ib0
[root@linux root]# ip a s dev bond0


