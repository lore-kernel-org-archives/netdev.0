From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Fw: [Bug 66051] New: RTNL: assertion failed at the beginning of
 bond_set_rx_mode(struct net_device *bond_dev)
Date: Fri, 29 Nov 2013 10:43:42 -0800
Message-ID: <20131129104342.579552e6@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:64018 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754228Ab3K2Sno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 13:43:44 -0500
Received: by mail-pb0-f50.google.com with SMTP id rr13so14991161pbb.9
        for <netdev@vger.kernel.org>; Fri, 29 Nov 2013 10:43:44 -0800 (PST)
Received: from nehalam.linuxnetplumber.net (static-50-53-83-51.bvtn.or.frontiernet.net. [50.53.83.51])
        by mx.google.com with ESMTPSA id xn12sm68022642pac.12.2013.11.29.10.43.43
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 29 Nov 2013 10:43:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Begin forwarded message:

Date: Thu, 28 Nov 2013 02:56:57 -0800
From: "bugzilla-daemon@bugzilla.kernel.org" <bugzilla-daemon@bugzilla.kernel.org>
To: "stephen@networkplumber.org" <stephen@networkplumber.org>
Subject: [Bug 66051] New: RTNL: assertion failed at the beginning of bond_set_rx_mode(struct net_device *bond_dev)


https://bugzilla.kernel.org/show_bug.cgi?id=66051

            Bug ID: 66051
           Summary: RTNL: assertion failed at the beginning of
                    bond_set_rx_mode(struct net_device *bond_dev)
           Product: Networking
           Version: 2.5
    Kernel Version: 3.12.1
          Hardware: All
                OS: Linux
              Tree: Mainline
            Status: NEW
          Severity: normal
          Priority: P1
         Component: Other
          Assignee: shemminger@linux-foundation.org
          Reporter: guanx.bac@gmail.com
        Regression: No

Created attachment 116541
  --> https://bugzilla.kernel.org/attachment.cgi?id=116541&action=edit
Kernel configuration for Linux-3.12.1

With the following configuration (attached ".config") I always get this
assertion failure with an active-backup bonding over two links (one rtl-8110sc
and one rtl-8139) but the system works fine as far as I can tell --
[ ... ... ...]
[    8.025194] 8139too: 8139too Fast Ethernet driver 0.9.28
[    8.025327] pci 0000:00:1e.0: setting latency timer to 64
[    8.025959] 8139too 0000:03:02.0 eth0: RealTek RTL8139 at 0x0001e800,
00:e0:7d:c6:56:d6, IRQ 22
[    8.026094] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
[    8.026239] r8169 0000:03:05.0 (unregistered net_device): not PCI Express
[    8.026514] r8169 0000:03:05.0 eth1: RTL8169sc/8110sc at 0xf862e800,
00:22:15:c0:29:40, XID 18000000 IR
Q 18
[    8.027592] r8169 0000:03:05.0 eth1: jumbo features [frames: 7152 bytes, tx
checksumming: ok]
[ ... ... ...]
[   11.690055] bonding: Ethernet Channel Bonding Driver: v3.7.1 (April 27,
2011)
[   11.690145] bonding: MII link monitoring set to 100 ms
[   11.730769] r8169 0000:03:05.0 eth0: link down
[   11.730855] r8169 0000:03:05.0 eth0: link down
[   11.731570] bonding: bond0: enslaving eth0 as a backup interface with a down
link.
[   11.732180] 8139too 0000:03:02.0 eth1: link up, 100Mbps, full-duplex, lpa
0xC5E1
[   11.732344] bonding: bond0: enslaving eth1 as a backup interface with an up
link.
[   11.813345] bonding: bond0: link status definitely up for interface eth1,
100 Mbps full duplex.
[   11.813478] bonding: bond0: making interface eth1 the new active one.
[   11.813596] bonding: bond0: first active interface up!
[ ... ... ...]
[   17.016528] r8169 0000:03:05.0 eth0: link up
[   17.113344] bonding: bond0: link status up for interface eth0, enabling it
in 300 ms.
[   17.413348] bonding: bond0: link status definitely up for interface eth0,
1000 Mbps full duplex.
[   17.413355] bonding: bond0: making interface eth0 the new active one.
[ ... ... ...]
[   27.983386] RTNL: assertion failed at drivers/net/bonding/bond_main.c (3398)
[   27.983394] CPU: 0 PID: 0 Comm: swapper/0 Tainted: P           O 3.12.1-smp
#1
[   27.983397] Hardware name: System manufacturer System Product
Name/P5KPL/1600, BIOS 0512    03/16/2009
[   27.983400]  00000000 00000000 f480bd6c c14fe81d f4a6e000 f480bd8c fbdd329d
fbde07e8
[   27.983407]  fbde07c8 00000d46 f4a6e000 fbddfb40 f4a6e146 f480bd9c c144638b
f4a6e000
[   27.983413]  00000000 f480bdc0 c1449f57 00000005 00000000 00000000 f480bddc
f420bc80
[   27.983420] Call Trace:
[   27.983433]  [<c14fe81d>] dump_stack+0x41/0x52
[   27.983445]  [<fbdd329d>] bond_set_rx_mode+0xad/0xc0 [bonding]
[   27.983452]  [<c144638b>] __dev_set_rx_mode+0x4b/0x90
[   27.983456]  [<c1449f57>] __dev_mc_add+0x57/0x70
[   27.983460]  [<c1449f7f>] dev_mc_add+0xf/0x20
[   27.983477]  [<fbf2677b>] igmp6_group_added+0x14b/0x180 [ipv6]
[   27.983483]  [<c1120000>] ? inc_cluster_info_page+0x60/0x90
[   27.983497]  [<fbf27c7b>] ? ipv6_dev_mc_inc+0xcb/0x350 [ipv6]
[   27.983514]  [<fbf27dbf>] ipv6_dev_mc_inc+0x20f/0x350 [ipv6]
[   27.983522]  [<fbf19890>] ? fib6_del+0x500/0x500 [ipv6]
[   27.983528]  [<fbf0f7d6>] addrconf_join_solict+0x56/0x60 [ipv6]
[   27.983533]  [<fbf0736a>] ipv6_dev_ac_inc+0x15a/0x1d0 [ipv6]
[   27.983539]  [<fbf0d9dd>] addrconf_join_anycast+0x9d/0xb0 [ipv6]
[   27.983546]  [<fbf0faa7>] __ipv6_ifa_notify+0x267/0x2c0 [ipv6]
[   27.983552]  [<fbf0fb29>] ipv6_ifa_notify+0x29/0x40 [ipv6]
[   27.983558]  [<fbf0fb76>] addrconf_dad_completed+0x36/0x190 [ipv6]
[   27.983561]  [<c1058da4>] ? insert_work+0x54/0x90
[   27.983567]  [<fbf0fe11>] addrconf_dad_timer+0x141/0x170 [ipv6]
[   27.983570]  [<c104d4dd>] call_timer_fn+0x2d/0xe0
[   27.983574]  [<c132c88c>] ? scsi_finish_command+0x9c/0xd0
[   27.983580]  [<fbf0fcd0>] ? addrconf_dad_completed+0x190/0x190 [ipv6]
[   27.983583]  [<c104d8c1>] run_timer_softirq+0x161/0x1e0
[   27.983589]  [<fbf0fcd0>] ? addrconf_dad_completed+0x190/0x190 [ipv6]
[   27.983592]  [<c1047849>] __do_softirq+0xb9/0x1d0
[   27.983595]  [<c1047790>] ? cpu_callback+0x160/0x160
[   27.983596]  <IRQ>  [<c1047aa5>] ? irq_exit+0x85/0x90
[   27.983601]  [<c15058f8>] ? smp_apic_timer_interrupt+0x38/0x50
[   27.983604]  [<c1504bc4>] ? apic_timer_interrupt+0x34/0x3c
[   27.983608]  [<c100a5c9>] ? default_idle+0x19/0xa0
[   27.983610]  [<c100ac6e>] ? arch_cpu_idle+0x1e/0x30
[   27.983613]  [<c108be5b>] ? cpu_startup_entry+0x9b/0x1e0
[   27.983616]  [<c1069328>] ? complete+0x48/0x50
[   27.983619]  [<c14f78c7>] ? rest_init+0x67/0x70
[   27.983624]  [<c1789ab9>] ? start_kernel+0x3a8/0x3ae
[   27.983626]  [<c1789548>] ? repair_env_string+0x51/0x51
[   27.983628]  [<c1789378>] ? i386_start_kernel+0x12e/0x131

-- 
You are receiving this mail because:
You are the assignee for the bug.
