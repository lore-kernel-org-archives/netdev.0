From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Tue, 03 Nov 2015 22:24:15 +0200
Message-ID: <f970215bd46efe3ea3dc5c7fccfa0509@visp.net.lb>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
 <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
 <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
 <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:34234 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932414AbbKCUYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 15:24:19 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 73365480FAE
	for <netdev@vger.kernel.org>; Tue,  3 Nov 2015 22:24:17 +0200 (EET)
In-Reply-To: <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-11-03 21:49, Eric Dumazet wrote:
> 
> Well, I am telling you.
> 
> Say no to people advising to turn off GRO/TSO.
> 
> If you were the guy adviding others to do so, it is time to see the
> light.
> 
> Lets fix the bugs if any, instead of spreading disinformation.
> 
> I am so tired of telling these very simple facts guys.
> 
> If you prefer, continue to work on linux-2.0 but don't ask help on
> netdev.
I wont argue on that, you are right.
Ok, then it is a bit offtopic in current case, different setup, but i 
know this one has easy to reproduce issues with offloading. but this is 
bug related to that, directly appearing when i enable tso/gso/gro. I am 
losing access to remote box, so max i can do right now:
ethtool -K eth0 tso on gso on gro on; sleep 5;ethtool -K eth0 tso off 
gso off gro off

No shapers, just plain nat. I suspect it might be specific to network 
card, but not sure.
4.1.4
02:00.0 "Class 0200" "8086" "10d3" "8086" "357a"

driver: e1000e
version: 2.3.2-k
firmware-version: 0.13-4
bus-info: 0000:00:19.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: no

But after that messages, honestly i don't know where to dig.

[6606122.904234] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[6606122.904234]   TDH                  <a5>
[6606122.904234]   TDT                  <ad>
[6606122.904234]   next_to_use          <ad>
[6606122.904234]   next_to_clean        <a3>
[6606122.904234] buffer_info[next_to_clean]:
[6606122.904234]   time_stamp           <12761e88c>
[6606122.904234]   next_to_watch        <a5>
[6606122.904234]   jiffies              <12761e928>
[6606122.904234]   next_to_watch.status <0>
[6606122.904234] MAC Status             <40080083>
[6606122.904234] PHY Status             <796d>
[6606122.904234] PHY 1000BASE-T Status  <3800>
[6606122.904234] PHY Extended Status    <3000>
[6606122.904234] PCI Status             <10>
[6606124.903733] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[6606124.903733]   TDH                  <a5>
[6606124.903733]   TDT                  <ad>
[6606124.903733]   next_to_use          <ad>
[6606124.903733]   next_to_clean        <a3>
[6606124.903733] buffer_info[next_to_clean]:
[6606124.903733]   time_stamp           <12761e88c>
[6606124.903733]   next_to_watch        <a5>
[6606124.903733]   jiffies              <12761e9f0>
[6606124.903733]   next_to_watch.status <0>
[6606124.903733] MAC Status             <40080083>
[6606124.903733] PHY Status             <796d>
[6606124.903733] PHY 1000BASE-T Status  <3800>
[6606124.903733] PHY Extended Status    <3000>
[6606124.903733] PCI Status             <10>
[6606126.903291] e1000e 0000:00:19.0 eth0: Detected Hardware Unit Hang:
[6606126.903291]   TDH                  <a5>
[6606126.903291]   TDT                  <ad>
[6606126.903291]   next_to_use          <ad>
[6606126.903291]   next_to_clean        <a3>
[6606126.903291] buffer_info[next_to_clean]:
[6606126.903291]   time_stamp           <12761e88c>
[6606126.903291]   next_to_watch        <a5>
[6606126.903291]   jiffies              <12761eab8>
[6606126.903291]   next_to_watch.status <0>
[6606126.903291] MAC Status             <40080083>
[6606126.903291] PHY Status             <796d>
[6606126.903291] PHY 1000BASE-T Status  <3800>
[6606126.903291] PHY Extended Status    <3000>
[6606126.903291] PCI Status             <10>
[6606127.912352] ------------[ cut here ]------------
[6606127.912566] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:303 
dev_watchdog+0x180/0x1e6()
[6606127.912877] NETDEV WATCHDOG: eth0 (e1000e): transmit queue 0 timed 
out
[6606127.913067] Modules linked in: xt_CLASSIFY xt_set ipt_REJECT 
nf_reject_ipv4 nf_log_ipv4 nf_log_common xt_LOG xt_recent ipt_MASQUERADE 
nf_nat_masquerade_ipv4 xt_nat xt_tcpudp nf_nat_pptp nf_nat_proto_gre 
nf_conntrack_pptp nf_conntrack_proto_gre ip_set_hash_net ip_set 
nfnetlink iptable_mangle iptable_nat nf_conntrack_ipv4 nf_defrag_ipv4 
nf_nat_ipv4 nf_nat nf_conntrack iptable_filter ip_tables x_tables 
act_nat cls_u32 sch_ingress
[6606127.915843] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
4.1.4-build-0084 #1
[6606127.916035] Hardware name: Intel Corporation SandyBridge 
Platform/To be filled by O.E.M., BIOS 
S1200BT.86B.02.00.0041.120520121743 12/05/2012
[6606127.916356]  0000000000000009 ffff88042f003dd8 ffffffff81896390 
00000000000000fb
[6606127.916903]  ffff88042f003e28 ffff88042f003e18 ffffffff810bc024 
ffffffff820aad98
[6606127.917451]  ffffffff81830ab3 ffff8800be47c000 ffff88042a8dce00 
0000000000000001
[6606127.917991] Call Trace:
[6606127.918175]  <IRQ>  [<ffffffff81896390>] dump_stack+0x45/0x57
[6606127.918429]  [<ffffffff810bc024>] warn_slowpath_common+0x97/0xb1
[6606127.918621]  [<ffffffff81830ab3>] ? dev_watchdog+0x180/0x1e6
[6606127.918812]  [<ffffffff810bc07f>] warn_slowpath_fmt+0x41/0x43
[6606127.919007]  [<ffffffffa003930f>] ? nf_ct_delete+0x1ef/0x202 
[nf_conntrack]
[6606127.919201]  [<ffffffff81830ab3>] dev_watchdog+0x180/0x1e6
[6606127.919396]  [<ffffffffa0039322>] ? nf_ct_delete+0x202/0x202 
[nf_conntrack]
[6606127.919589]  [<ffffffff81830933>] ? dev_graft_qdisc+0x65/0x65
[6606127.919781]  [<ffffffff810ef971>] call_timer_fn.isra.27+0x17/0x6d
[6606127.919975]  [<ffffffff810f0235>] run_timer_softirq+0x1a0/0x1c4
[6606127.920169]  [<ffffffff810be861>] __do_softirq+0xc3/0x1b2
[6606127.920359]  [<ffffffff810bea9c>] irq_exit+0x37/0x7c
[6606127.920551]  [<ffffffff81028c2a>] 
smp_apic_timer_interrupt+0x3e/0x4a
[6606127.920745]  [<ffffffff8189d9b8>] apic_timer_interrupt+0x68/0x70
[6606127.920937]  <EOI>  [<ffffffff8100a34c>] ? mwait_idle+0x68/0x7e
[6606127.921189]  [<ffffffff8100aa07>] arch_cpu_idle+0xa/0xc
[6606127.921379]  [<ffffffff810e22af>] cpu_startup_entry+0x207/0x238
[6606127.921574]  [<ffffffff818915d0>] rest_init+0x77/0x79
[6606127.921768]  [<ffffffff820c7de8>] start_kernel+0x3f6/0x403
[6606127.921957]  [<ffffffff820c77ea>] ? set_init_arg+0x55/0x55
[6606127.922149]  [<ffffffff820c7442>] 
x86_64_start_reservations+0x2a/0x2c
[6606127.922341]  [<ffffffff820c7500>] x86_64_start_kernel+0xbc/0xc0
[6606127.922532] ---[ end trace c83a65027c0499d1 ]---
[6606127.922734] e1000e 0000:00:19.0 eth0: Reset adapter unexpectedly
[6606131.827524] e1000e: eth0 NIC Link is Up 1000 Mbps Full Duplex, Flow 
Control: None
