From: Phil Oester <kernel@linuxace.com>
Subject: 3.7 networking regression - bisected
Date: Fri, 15 Feb 2013 15:27:52 -0800
Message-ID: <20130215232752.GA19796@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:53702 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816Ab3BOX15 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 18:27:57 -0500
Received: by mail-pa0-f53.google.com with SMTP id bg4so1939585pad.40
        for <netdev@vger.kernel.org>; Fri, 15 Feb 2013 15:27:57 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since upgrading a box to 3.7, I've been seeing e1000e issues on one box:

	e1000e 0000:00:19.0: eth2: Detected Hardware Unit Hang

While 3.6 worked fine.  I bisected the problem down to commit
69b08f62e17439ee3d436faf0b9a7ca6fffb78db ("net: use bigger pages in
__netdev_alloc_frag").  Running 3.7.x without that commit is 
currently working fine.  

I have other boxes on 3.7 with e1000e that are not experiencing this
problem.  The difference on this box is it runs at 100mb, which
disables TSO:

	e1000e 0000:00:19.0 eth2: 10/100 speed: disabling TSO

So maybe the problem doesn't occur with TSO enabled?  Either that,
or there is something unique about the traffic pattern this box is seeing.

Full log entries below.

Phil Oester



Feb 15 17:38:19 char1 kernel: e1000e 0000:00:19.0: eth2: Detected Hardware Unit Hang:
Feb 15 17:38:19 char1 kernel:  TDH                  <f>
Feb 15 17:38:19 char1 kernel:  TDT                  <22>
Feb 15 17:38:19 char1 kernel:  next_to_use          <22>
Feb 15 17:38:19 char1 kernel:  next_to_clean        <d>
Feb 15 17:38:19 char1 kernel: buffer_info[next_to_clean]:
Feb 15 17:38:19 char1 kernel:  time_stamp           <10001bb67>
Feb 15 17:38:19 char1 kernel:  next_to_watch        <f>
Feb 15 17:38:19 char1 kernel:  jiffies              <10001bfa9>
Feb 15 17:38:19 char1 kernel:  next_to_watch.status <0>
Feb 15 17:38:19 char1 kernel: MAC Status             <80243>
Feb 15 17:38:19 char1 kernel: PHY Status             <792d>
Feb 15 17:38:19 char1 kernel: PHY 1000BASE-T Status  <0>
Feb 15 17:38:19 char1 kernel: PHY Extended Status    <3000>
Feb 15 17:38:19 char1 kernel: PCI Status             <10>
Feb 15 17:38:21 char1 kernel: e1000e 0000:00:19.0: eth2: Detected Hardware Unit Hang:
Feb 15 17:38:21 char1 kernel:  TDH                  <f>
Feb 15 17:38:21 char1 kernel:  TDT                  <22>
Feb 15 17:38:21 char1 kernel:  next_to_use          <22>
Feb 15 17:38:21 char1 kernel:  next_to_clean        <d>
Feb 15 17:38:21 char1 kernel: buffer_info[next_to_clean]:
Feb 15 17:38:21 char1 kernel:  time_stamp           <10001bb67>
Feb 15 17:38:21 char1 kernel:  next_to_watch        <f>
Feb 15 17:38:21 char1 kernel:  jiffies              <10001c071>
Feb 15 17:38:21 char1 kernel:  next_to_watch.status <0>
Feb 15 17:38:21 char1 kernel: MAC Status             <80243>
Feb 15 17:38:21 char1 kernel: PHY Status             <792d>
Feb 15 17:38:21 char1 kernel: PHY 1000BASE-T Status  <0>
Feb 15 17:38:21 char1 kernel: PHY Extended Status    <3000>
Feb 15 17:38:21 char1 kernel: PCI Status             <10>
Feb 15 17:38:23 char1 kernel: e1000e 0000:00:19.0: eth2: Detected Hardware Unit Hang:
Feb 15 17:38:23 char1 kernel:  TDH                  <f>
Feb 15 17:38:23 char1 kernel:  TDT                  <22>
Feb 15 17:38:23 char1 kernel:  next_to_use          <22>
Feb 15 17:38:23 char1 kernel:  next_to_clean        <d>
Feb 15 17:38:23 char1 kernel: buffer_info[next_to_clean]:
Feb 15 17:38:23 char1 kernel:  time_stamp           <10001bb67>
Feb 15 17:38:23 char1 kernel:  next_to_watch        <f>
Feb 15 17:38:23 char1 kernel:  jiffies              <10001c139>
Feb 15 17:38:23 char1 kernel:  next_to_watch.status <0>
Feb 15 17:38:23 char1 kernel: MAC Status             <80243>
Feb 15 17:38:23 char1 kernel: PHY Status             <792d>
Feb 15 17:38:23 char1 kernel: PHY 1000BASE-T Status  <0>
Feb 15 17:38:23 char1 kernel: PHY Extended Status    <3000>
Feb 15 17:38:23 char1 kernel: PCI Status             <10>
Feb 15 17:38:25 char1 kernel: e1000e 0000:00:19.0: eth2: Detected Hardware Unit Hang:
Feb 15 17:38:25 char1 kernel:  TDH                  <f>
Feb 15 17:38:25 char1 kernel:  TDT                  <22>
Feb 15 17:38:25 char1 kernel:  next_to_use          <22>
Feb 15 17:38:25 char1 kernel:  next_to_clean        <d>
Feb 15 17:38:25 char1 kernel: buffer_info[next_to_clean]:
Feb 15 17:38:25 char1 kernel:  time_stamp           <10001bb67>
Feb 15 17:38:25 char1 kernel:  next_to_watch        <f>
Feb 15 17:38:25 char1 kernel:  jiffies              <10001c201>
Feb 15 17:38:25 char1 kernel:  next_to_watch.status <0>
Feb 15 17:38:25 char1 kernel: MAC Status             <80243>
Feb 15 17:38:25 char1 kernel: PHY Status             <792d>
Feb 15 17:38:25 char1 kernel: PHY 1000BASE-T Status  <0>
Feb 15 17:38:25 char1 kernel: PHY Extended Status    <3000>
Feb 15 17:38:25 char1 kernel: PCI Status             <10>
Feb 15 17:38:27 char1 kernel: e1000e 0000:00:19.0: eth2: Detected Hardware Unit Hang:
Feb 15 17:38:27 char1 kernel:  TDH                  <f>
Feb 15 17:38:27 char1 kernel:  TDT                  <22>
Feb 15 17:38:27 char1 kernel:  next_to_use          <22>
Feb 15 17:38:27 char1 kernel:  next_to_clean        <d>
Feb 15 17:38:27 char1 kernel: buffer_info[next_to_clean]:
Feb 15 17:38:27 char1 kernel:  time_stamp           <10001bb67>
Feb 15 17:38:27 char1 kernel:  next_to_watch        <f>
Feb 15 17:38:27 char1 kernel:  jiffies              <10001c2c9>
Feb 15 17:38:27 char1 kernel:  next_to_watch.status <0>
Feb 15 17:38:27 char1 kernel: MAC Status             <80243>
Feb 15 17:38:27 char1 kernel: PHY Status             <792d>
Feb 15 17:38:27 char1 kernel: PHY 1000BASE-T Status  <0>
Feb 15 17:38:27 char1 kernel: PHY Extended Status    <3000>
Feb 15 17:38:27 char1 kernel: PCI Status             <10>
Feb 15 17:38:28 char1 kernel: ------------[ cut here ]------------
Feb 15 17:38:28 char1 kernel: WARNING: at net/sched/sch_generic.c:255 dev_watchdog+0x239/0x250()
Feb 15 17:38:28 char1 kernel: Hardware name: OptiPlex 755                 
Feb 15 17:38:28 char1 kernel: NETDEV WATCHDOG: eth2 (e1000e): transmit queue 0 timed out
Feb 15 17:38:28 char1 kernel: Modules linked in: iptable_nat nf_nat_ipv4 xt_LOG xt_limit xt_pkttype xt_tcpudp xt_state xt_iprange xt_multiport iptable_filter ip_tables x_tables nf_nat_tftp nf_nat_ftp nf_nat nf_conntrack_tftp nf_conntrack_ftp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack e1000e e1000 lpc_ich coretemp hwmon mfd_core ahci libahci
Feb 15 17:38:28 char1 kernel: Pid: 0, comm: swapper/1 Not tainted 3.6.0-2.fc16.x86_64 #1
Feb 15 17:38:28 char1 kernel: Call Trace:
Feb 15 17:38:28 char1 kernel: <IRQ>  [<ffffffff8128c300>] ? dev_watchdog+0x170/0x250
Feb 15 17:38:28 char1 kernel: [<ffffffff8102ac6b>] ? warn_slowpath_common+0x7b/0xc0
Feb 15 17:38:28 char1 kernel: [<ffffffff8102ad65>] ? warn_slowpath_fmt+0x45/0x50
Feb 15 17:38:28 char1 kernel: [<ffffffff8128c3c9>] ? dev_watchdog+0x239/0x250
Feb 15 17:38:28 char1 kernel: [<ffffffff81036bb6>] ? run_timer_softirq+0x106/0x230
Feb 15 17:38:28 char1 kernel: [<ffffffff8128c190>] ? pfifo_fast_dequeue+0xe0/0xe0
Feb 15 17:38:28 char1 kernel: [<ffffffff81031af8>] ? __do_softirq+0xa8/0x150
Feb 15 17:38:28 char1 kernel: [<ffffffff812fd3ec>] ? call_softirq+0x1c/0x26
Feb 15 17:38:28 char1 kernel: [<ffffffff81003a1d>] ? do_softirq+0x4d/0x80
Feb 15 17:38:28 char1 kernel: [<ffffffff81031e0e>] ? irq_exit+0x8e/0xb0
Feb 15 17:38:28 char1 kernel: [<ffffffff8101c628>] ? smp_apic_timer_interrupt+0x68/0xa0
Feb 15 17:38:28 char1 kernel: [<ffffffff812fcd07>] ? apic_timer_interrupt+0x67/0x70
Feb 15 17:38:28 char1 kernel: <EOI>  [<ffffffff81061690>] ? __tick_nohz_idle_enter+0x330/0x410
Feb 15 17:38:28 char1 kernel: [<ffffffff810098a1>] ? mwait_idle+0x51/0x70
Feb 15 17:38:28 char1 kernel: [<ffffffff8100a1b6>] ? cpu_idle+0x86/0xd0
Feb 15 17:38:28 char1 kernel: ---[ end trace 50a96207e385a66c ]---
Feb 15 17:38:28 char1 kernel: e1000e 0000:00:19.0: eth2: Reset adapter
Feb 15 17:38:29 char1 kernel: e1000e: eth2 NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
