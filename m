From: Sylvain Munaut <s.munaut@whatever-company.com>
Subject: netconsole leads to stalled CPU task
Date: Tue, 21 Aug 2012 17:13:43 +0200
Message-ID: <CAF6-1L79tec_0L7xuEDznjGQdwZQV34CgdNuGo=TJ4dPGTHZag@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f46.google.com ([209.85.212.46]:53375 "EHLO
	mail-vb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754549Ab2HUPNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2012 11:13:44 -0400
Received: by mail-vb0-f46.google.com with SMTP id ff1so6604445vbb.19
        for <netdev@vger.kernel.org>; Tue, 21 Aug 2012 08:13:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


I'm trying to use the netconsole to feed kernel message to the outside
but this lead to a stall ...

This only happens in a fairly specific configuration where you have a
bridge over vlan over bonding.
I tested with only (bridge over vlan) and (vlan over bonding) and
those work fine.


bash# modprobe netconsole
netconsole=8888@10.208.1.30/mgmt,8000@10.208.1.3/00:16:3e:1a:37:37
[... never returns ... ]

dmesg:

[  130.672942] netpoll: netconsole: local port 8888
[  130.673206] netpoll: netconsole: local IP 10.208.1.30
[  130.673460] netpoll: netconsole: interface 'mgmt'
[  130.673735] netpoll: netconsole: remote port 8000
[  130.673984] netpoll: netconsole: remote IP 10.208.1.3
[  130.674231] netpoll: netconsole: remote ethernet address 00:16:3e:1a:37:37
[  132.975290] console [netcon0] enabled
[  132.975541] netconsole: network logging started
[  190.677624] INFO: rcu_preempt detected stalls on CPUs/tasks: { 15}
(detected by 2, t=60002 jiffies)
[  190.678218] INFO: Stall ended before state dump start
[  370.682595] INFO: rcu_preempt detected stalls on CPUs/tasks: { 15}
(detected by 2, t=240007 jiffies)
[  370.683197] INFO: Stall ended before state dump start
[  451.664596] INFO: rcu_bh detected stalls on CPUs/tasks: { 15}
(detected by 16, t=60004 jiffies)
[  451.665190] INFO: Stall ended before state dump start
[  550.687619] INFO: rcu_preempt detected stalls on CPUs/tasks: { 15}
(detected by 16, t=420012 jiffies)
[  550.688211] INFO: Stall ended before state dump start
[  631.669621] INFO: rcu_bh detected stalls on CPUs/tasks: { 15}
(detected by 2, t=240009 jiffies)
[  631.670220] INFO: Stall ended before state dump start


ifconfig:

bond0     Link encap:Ethernet  HWaddr 18:03:73:ed:67:ad
          inet6 addr: fe80::1a03:73ff:feed:67ad/64 Scope:Link
          UP BROADCAST RUNNING MASTER MULTICAST  MTU:1500  Metric:1
          RX packets:735 errors:0 dropped:1 overruns:0 frame:0
          TX packets:127 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:99136 (96.8 KiB)  TX bytes:40635 (39.6 KiB)

bond0.1   Link encap:Ethernet  HWaddr 18:03:73:ed:67:ad
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:283 errors:0 dropped:0 overruns:0 frame:0
          TX packets:108 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:41948 (40.9 KiB)  TX bytes:37915 (37.0 KiB)

eth0      Link encap:Ethernet  HWaddr 18:03:73:ed:67:ad
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:450 errors:0 dropped:0 overruns:0 frame:0
          TX packets:10 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:52085 (50.8 KiB)  TX bytes:1053 (1.0 KiB)

eth2      Link encap:Ethernet  HWaddr 18:03:73:ed:67:ad
          UP BROADCAST RUNNING SLAVE MULTICAST  MTU:1500  Metric:1
          RX packets:285 errors:0 dropped:1 overruns:0 frame:0
          TX packets:117 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:47051 (45.9 KiB)  TX bytes:39582 (38.6 KiB)

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)

mgmt      Link encap:Ethernet  HWaddr 18:03:73:ed:67:ad
          inet addr:10.208.1.30  Bcast:10.208.1.255  Mask:255.255.255.0
          inet6 addr: fe80::1a03:73ff:feed:67ad/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:280 errors:0 dropped:0 overruns:0 frame:0
          TX packets:108 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:41713 (40.7 KiB)  TX bytes:37915 (37.0 KiB)


Cheers,

    Sylvain
