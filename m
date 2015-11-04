From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Wed, 04 Nov 2015 06:49:59 +0200
Message-ID: <f471b1af41bdbe09d214b029dc75221e@visp.net.lb>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
 <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
 <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
 <f970215bd46efe3ea3dc5c7fccfa0509@visp.net.lb>
 <1446585826.23275.78.camel@edumazet-glaptop2.roam.corp.google.com>
 <0394a0a8c8f65e367a596274719ed759@visp.net.lb>
 <1446611317.4184.3.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:42989 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755192AbbKDEuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 23:50:03 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 77A40481717
	for <netdev@vger.kernel.org>; Wed,  4 Nov 2015 06:50:01 +0200 (EET)
In-Reply-To: <1446611317.4184.3.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-11-04 06:28, Eric Dumazet wrote:
> On Wed, 2015-11-04 at 06:12 +0200, Denys Fedoryshchenko wrote:
>> Just enabling gro or gso (or together) is fine there. Thanks for 
>> advice.
>> Seems only tso causing problems.
>> Also i guess if i keep tso disabled, it will solve my MTU issues (i 
>> had
>> once issue, that traffic heading to pppoe users,
>> who have 14xx mtu, was blocked, when offloading enabled on transit
>> server, but can't reproduce it quickly again).
>> Should i try to report to e1000e maintainers this bug? On similar 
>> setup
>> it is happening only at specific locations,
>> but i am not definitely sure what can be the reason.
> 
> Not sure, have you tried per chance latest kernel (linux-4.3) for this
> e1000e issue ?
> 
> Are you using vlan tags on this NIC ?
Tested now, can be reproduced on 4.3 as well.
What is interesting, if i enable tso alone, and leave gso/gro off - it 
is working fine. gso+gro on, tso off - fine also.
But if i enable them all together - i trigger the bug.

[   71.699687] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[   71.699687]   TDH                  <96>
[   71.699687]   TDT                  <9c>
[   71.699687]   next_to_use          <9c>
[   71.699687]   next_to_clean        <92>
[   71.699687] buffer_info[next_to_clean]:
[   71.699687]   time_stamp           <fffc78bd>
[   71.699687]   next_to_watch        <96>
[   71.699687]   jiffies              <fffc843c>
[   71.699687]   next_to_watch.status <0>
[   71.699687] MAC Status             <40080083>
[   71.699687] PHY Status             <796d>
[   71.699687] PHY 1000BASE-T Status  <3800>
[   71.699687] PHY Extended Status    <3000>
[   71.699687] PCI Status             <10>
[   73.699241] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[   73.699241]   TDH                  <96>
[   73.699241]   TDT                  <9c>
[   73.699241]   next_to_use          <9c>
[   73.699241]   next_to_clean        <92>
[   73.699241] buffer_info[next_to_clean]:
[   73.699241]   time_stamp           <fffc78bd>
[   73.699241]   next_to_watch        <96>
[   73.699241]   jiffies              <fffc8c0c>
[   73.699241]   next_to_watch.status <0>
[   73.699241] MAC Status             <40080083>
[   73.699241] PHY Status             <796d>
[   73.699241] PHY 1000BASE-T Status  <3800>
[   73.699241] PHY Extended Status    <3000>
[   73.699241] PCI Status             <10>
[   75.698775] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[   75.698775]   TDH                  <96>
[   75.698775]   TDT                  <9c>
[   75.698775]   next_to_use          <9c>
[   75.698775]   next_to_clean        <92>
[   75.698775] buffer_info[next_to_clean]:
[   75.698775]   time_stamp           <fffc78bd>
[   75.698775]   next_to_watch        <96>
[   75.698775]   jiffies              <fffc93dc>
[   75.698775]   next_to_watch.status <0>
[   75.698775] MAC Status             <40080083>
[   75.698775] PHY Status             <796d>
[   75.698775] PHY 1000BASE-T Status  <3800>
[   75.698775] PHY Extended Status    <3000>
[   75.698775] PCI Status             <10>
[   76.709871] ------------[ cut here ]------------
[   76.710075] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:303 
dev_watchdog+0x17c/0x1e2()
[   76.710383] NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed 
out
[   76.710572] Modules linked in: xt_CLASSIFY xt_set ipt_REJECT 
nf_reject_ipv4 nf_log_ipv4 nf_log_common xt_LOG xt_recent ipt_MASQUERADE 
nf_nat_masquerade_ipv4 xt_nat xt_tcpudp nf_nat_pptp nf_nat_proto_gre 
nf_conntrack_pptp nf_conntrack_proto_gre ip_set_hash_net ip_set 
nfnetlink iptable_mangle iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 
nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables 
act_nat cls_u32 sch_ingress
[   76.713354] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
4.3.0-build-0087 #1
[   76.713547] Hardware name: Intel Corporation SandyBridge Platform/To 
be filled by O.E.M., BIOS S1200BT.86B.02.00.0041.120520121743 12/05/2012
[   76.713868]  0000000000000000 ffff88042f003e08 ffffffff81259d1d 
ffff88042f003e50
[   76.714413]  ffff88042f003e40 ffffffff810bda73 ffffffff818654a3 
ffff88042c290000
[   76.714946]  ffff8800be758c00 0000000000000001 0000000000000000 
ffff88042f003ea0
[   76.715481] Call Trace:
[   76.715657]  <IRQ>  [<ffffffff81259d1d>] dump_stack+0x44/0x55
[   76.715908]  [<ffffffff810bda73>] warn_slowpath_common+0x95/0xae
[   76.716095]  [<ffffffff818654a3>] ? dev_watchdog+0x17c/0x1e2
[   76.716281]  [<ffffffff810bdad3>] warn_slowpath_fmt+0x47/0x49
[   76.716470]  [<ffffffff810f4bcc>] ? mod_timer_pinned+0xaf/0xbe
[   76.716662]  [<ffffffff818654a3>] dev_watchdog+0x17c/0x1e2
[   76.716850]  [<ffffffff81865327>] ? dev_graft_qdisc+0x65/0x65
[   76.717039]  [<ffffffff810f4db8>] call_timer_fn.isra.26+0x17/0x6d
[   76.717227]  [<ffffffff810f4f80>] run_timer_softirq+0x172/0x193
[   76.717418]  [<ffffffff810c0588>] __do_softirq+0xba/0x1a9
[   76.717606]  [<ffffffff810c07bf>] irq_exit+0x37/0x7c
[   76.717795]  [<ffffffff81029c06>] smp_apic_timer_interrupt+0x3d/0x48
[   76.717988]  [<ffffffff818cdccc>] apic_timer_interrupt+0x7c/0x90
[   76.718179]  <EOI>  [<ffffffff8100aed5>] ? mwait_idle+0x68/0x7e
[   76.718436]  [<ffffffff8100b2d8>] arch_cpu_idle+0xa/0xc
[   76.718625]  [<ffffffff810e5822>] default_idle_call+0x27/0x29
[   76.718816]  [<ffffffff810e5945>] cpu_startup_entry+0x121/0x1da
[   76.719008]  [<ffffffff818c8970>] rest_init+0x77/0x79
[   76.719195]  [<ffffffff820cde02>] start_kernel+0x40f/0x41c
[   76.719384]  [<ffffffff820cd7e2>] ? set_init_arg+0x55/0x55
[   76.719572]  [<ffffffff820cd442>] x86_64_start_reservations+0x2a/0x2c
[   76.719764]  [<ffffffff820cd4ff>] x86_64_start_kernel+0xbb/0xbe
[   76.719955] ---[ end trace 6e1862989bd54a50 ]---
[   76.720145] e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
[   80.568051] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: None
