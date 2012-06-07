From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Difficulties to get 1Gbps on be2net ethernet card
Date: Thu, 7 Jun 2012 14:54:44 +0200
Message-ID: <CAL8zT=i2EkZLz3J5ib1tLnOuXt=Buf0sCwr7UbQWRE3B4oB+JQ@mail.gmail.com>
References: <CAL8zT=hHAc5-wGMKgumV=K9jG6tDxzej9Dffe9UYQ24gdWQRtw@mail.gmail.com>
 <CAL8zT=jKhRjVCdYRCerMzimxPAhP5Gi+JBBfuKjG-rfg-LMoVw@mail.gmail.com>
 <1338360536.2760.85.camel@edumazet-glaptop> <CAL8zT=h2hoTWDMpTe8P-xfm-USXD6spx8fFVmm1UXyOfuuqhZw@mail.gmail.com>
 <1338361587.2760.94.camel@edumazet-glaptop> <CAL8zT=jHWhDdv-DyXL8XnL8qRc7o-jZfA7ADU-qt54hB5aLyCw@mail.gmail.com>
 <CAL8zT=gJT1Frn_44SU0CrpZjPxwC_VuHFE4k9jvOGNmFomzhHA@mail.gmail.com>
 <3367B80B08154D42A3B2BC708B5D41F647C678B73F@EXMAIL.ad.emulex.com>
 <CAL8zT=iP+5o11am67ZBVOd=QrOfcjFWDydiuM9RrrAKe_k7LZw@mail.gmail.com>
 <CAL8zT=ggT7Y2on6qmsp3u9CLOCwd6nOr3VjQfEsGZzA+O6us0A@mail.gmail.com>
 <1338980484.2760.4219.camel@edumazet-glaptop> <CAL8zT=hHDPnvRFcQ0w+D=AP+QK6ic4X=tva6Yw_XGwuTbAYjhQ@mail.gmail.com>
 <CAL8zT=jGHo82mo-s8Tfs9LWzfu2GkrS4eZJoeOpHhpXHMr6csg@mail.gmail.com>
 <CAL8zT=jY9YfdkBjk5VhwaSbzghCVUMXZZh+QAgc15LBBztczog@mail.gmail.com>
 <CAL8zT=g67JLZZjLF81+wxe9pmuPZ4EdpY1fHJMQNgcy9R6oBzg@mail.gmail.com> <1339072289.3494.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sathya.Perla@emulex.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:50074 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751800Ab2FGMzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 08:55:06 -0400
Received: by wibhj8 with SMTP id hj8so204951wib.1
        for <netdev@vger.kernel.org>; Thu, 07 Jun 2012 05:55:05 -0700 (PDT)
In-Reply-To: <1339072289.3494.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/6/7 Eric Dumazet <eric.dumazet@gmail.com>:
> On Thu, 2012-06-07 at 14:27 +0200, Jean-Michel Hautbois wrote:
>
>> I made some tests, and I didn't mention it : I am using the bonding
>> driver over my ethernet drivers (be2net/mlx4 etc.).
>> When I am using bonding, I need a big txqeuelen in order to send 2.4Gbps.
>> When I disable bonding, and use directly the NIC then I don't see any
>> drops in qdisc and it works well.
>> So, I think there is something between 2.6.26 and 3.0 in the bonding
>> driver which causes this issue.
>>
>
> What your bond configuration looks like ?
>
> cat /proc/net/bonding/bond0
cat /proc/net/bonding/bond1
Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

Bonding Mode: fault-tolerance (active-backup)
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 50
Up Delay (ms): 100
Down Delay (ms): 0

Slave Interface: eth1
MII Status: up
Speed: 4000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 68:b5:99:b9:8d:d4
Slave queue ID: 0

Slave Interface: eth9
MII Status: up
Speed: 4000 Mbps
Duplex: full
Link Failure Count: 0
Permanent HW addr: 78:e7:d1:68:bb:38
Slave queue ID: 0

> ifconfig -a
bond0     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d0
          inet addr:192.168.250.11  Bcast:192.168.250.255  Mask:255.255.255.0
          inet6 addr: fe80::6ab5:99ff:feb9:8dd0/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:6570 errors:0 dropped:74 overruns:0 frame:0
          TX packets:5208 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:900993 (879.8 KiB)  TX bytes:863735 (843.4 KiB)

bond1     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d4
          inet addr:192.168.2.1  Bcast:192.168.2.255  Mask:255.255.255.0
          inet6 addr: fe80::6ab5:99ff:feb9:8dd4/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:4096  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:15215387 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:61476524359 (57.2 GiB)

bond2     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d1
          inet addr:10.11.17.190  Bcast:10.11.17.255  Mask:255.255.255.128
          inet6 addr: fe80::6ab5:99ff:feb9:8dd1/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:1301996 errors:0 dropped:27 overruns:0 frame:0
          TX packets:959 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1760302182 (1.6 GiB)  TX bytes:502828 (491.0 KiB)

bond3     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d5
          inet6 addr: fe80::6ab5:99ff:feb9:8dd5/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:942641 errors:0 dropped:0 overruns:0 frame:0
          TX packets:40 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1278313720 (1.1 GiB)  TX bytes:2616 (2.5 KiB)

bond4     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d2
          inet addr:192.168.202.1  Bcast:192.168.202.255  Mask:255.255.255.0
          inet6 addr: fe80::6ab5:99ff:feb9:8dd2/64 Scope:Link
          UP BROADCAST MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:90 (90.0 B)

bond5     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d6
          inet addr:192.168.203.1  Bcast:192.168.203.255  Mask:255.255.255.0
          inet6 addr: fe80::6ab5:99ff:feb9:8dd6/64 Scope:Link
          UP BROADCAST MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:90 (90.0 B)

bond6     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d3
          inet6 addr: fe80::6ab5:99ff:feb9:8dd3/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:269 errors:0 dropped:0 overruns:0 frame:0
          TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:25531 (24.9 KiB)  TX bytes:1046 (1.0 KiB)

bond7     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d7
          UP BROADCAST MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

bond3.4   Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d5
          inet addr:192.168.201.1  Bcast:192.168.201.255  Mask:255.255.255.0
          inet6 addr: fe80::6ab5:99ff:feb9:8dd5/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:942641 errors:0 dropped:0 overruns:0 frame:0
          TX packets:34 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:1265116746 (1.1 GiB)  TX bytes:1980 (1.9 KiB)

bond6.7   Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d3
          inet addr:192.168.204.1  Bcast:192.168.204.255  Mask:255.255.255.0
          inet6 addr: fe80::6ab5:99ff:feb9:8dd3/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:269 errors:0 dropped:0 overruns:0 frame:0
          TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:21765 (21.2 KiB)  TX bytes:468 (468.0 B)

eth0      Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d0
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:6496 errors:0 dropped:0 overruns:0 frame:0
          TX packets:5208 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:896849 (875.8 KiB)  TX bytes:863735 (843.4 KiB)

eth1      Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d4
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:4096  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:15215387 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:61476524359 (57.2 GiB)

eth2      Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d1
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:1301996 errors:0 dropped:27 overruns:0 frame:0
          TX packets:959 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1760302182 (1.6 GiB)  TX bytes:502828 (491.0 KiB)

eth3      Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d5
          UP BROADCAST SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

eth4      Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d2
          UP BROADCAST SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

eth5      Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d6
          UP BROADCAST SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

eth6      Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d3
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:269 errors:0 dropped:0 overruns:0 frame:0
          TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:25531 (24.9 KiB)  TX bytes:1046 (1.0 KiB)

eth7      Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d7
          UP BROADCAST SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

eth8      Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d0
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:74 errors:0 dropped:74 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:4144 (4.0 KiB)  TX bytes:0 (0.0 B)

eth9      Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d4
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:4096  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

eth10     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d1
          UP BROADCAST SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

eth11     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d5
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:942641 errors:0 dropped:0 overruns:0 frame:0
          TX packets:40 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:1278313720 (1.1 GiB)  TX bytes:2616 (2.5 KiB)

eth12     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d2
          UP BROADCAST SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:90 (90.0 B)

eth13     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d6
          UP BROADCAST SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:90 (90.0 B)

eth14     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d3
          UP BROADCAST SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

eth15     Link encap:Ethernet  HWaddr 68:b5:99:b9:8d:d7
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:667883 errors:0 dropped:0 overruns:0 frame:0
          TX packets:667883 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:109537849 (104.4 MiB)  TX bytes:109537849 (104.4 MiB)


> tc -s -d qdisc
 tc -s -d qdisc
qdisc mq 0: dev eth0 root
 Sent 873668 bytes 5267 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth1 root
 Sent 61476524359 bytes 15215387 pkt (dropped 45683472, overlimits 0
requeues 17480)
 backlog 0b 0p requeues 17480
qdisc mq 0: dev eth2 root
 Sent 516248 bytes 983 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth3 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth4 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth5 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth6 root
 Sent 1022 bytes 13 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth7 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth8 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth9 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth10 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth11 root
 Sent 2448 bytes 40 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth12 root
 Sent 90 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth13 root
 Sent 90 bytes 1 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth14 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 backlog 0b 0p requeues 0
qdisc mq 0: dev eth15 root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
