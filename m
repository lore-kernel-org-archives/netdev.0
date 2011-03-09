From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: bonding can't change to another slave if you ifdown the active
 slave
Date: Wed, 9 Mar 2011 14:02:15 +0800
Message-ID: <20110309060215.GA16951@cr0.redhat.com>
References: <4D75D244.9070409@gmail.com>
 <il58p9$3ka$2@dough.gmane.org>
 <4D76E8A4.6080801@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: WANG Cong <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:54866 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751535Ab1CIGCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2011 01:02:42 -0500
Received: by vxi39 with SMTP id 39so196841vxi.19
        for <netdev@vger.kernel.org>; Tue, 08 Mar 2011 22:02:41 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <4D76E8A4.6080801@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2011 at 10:40:36AM +0800, Weiping Pan wrote:

<...>

>[root@localhost ~]# ifconfig
>bond0     Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
>          inet addr:192.168.1.2  Bcast:192.168.1.255  Mask:255.255.255.0
>          inet6 addr: fe80::a00:27ff:fe78:f641/64 Scope:Link
>          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
>          RX packets:40 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:25 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:0
>          RX bytes:19632 (19.1 KiB)  TX bytes:4070 (3.9 KiB)
>
>eth6      Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
>          inet addr:192.168.56.101  Bcast:192.168.56.255
>Mask:255.255.255.0
>          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
>          RX packets:21 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:13 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:1000
>          RX bytes:10158 (9.9 KiB)  TX bytes:1802 (1.7 KiB)
>
>eth7      Link encap:Ethernet  HWaddr 08:00:27:78:F6:41
>          inet addr:192.168.56.101  Bcast:192.168.56.255
>Mask:255.255.255.0
>          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
>          RX packets:19 errors:0 dropped:0 overruns:0 frame:0
>          TX packets:12 errors:0 dropped:0 overruns:0 carrier:0
>          collisions:0 txqueuelen:1000
>          RX bytes:9474 (9.2 KiB)  TX bytes:2268 (2.2 KiB)


It's weird that you bond two nic's into another different subnet.

>
>[root@localhost ~]# ping 192.168.1.100 -c 5
>PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
>64 bytes from 192.168.1.100: icmp_req=1 ttl=64 time=3.69 ms
>64 bytes from 192.168.1.100: icmp_req=2 ttl=64 time=0.242 ms
>64 bytes from 192.168.1.100: icmp_req=3 ttl=64 time=0.154 ms
>64 bytes from 192.168.1.100: icmp_req=4 ttl=64 time=0.270 ms
>64 bytes from 192.168.1.100: icmp_req=5 ttl=64 time=0.278 ms
>

What is your route table in your guest?


>[root@localhost ~]# ip link show
>1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
>    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>2: eth7: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc
>pfifo_fast master bond0 state UP qlen 1000
>    link/ether 08:00:27:78:f6:41 brd ff:ff:ff:ff:ff:ff
>3: eth6: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc
>pfifo_fast master bond0 state DOWN qlen 1000

Clearly this equals to pulling off the cable from eth6,
which is your first slave.

