From: nuclearcat@nuclearcat.com
Subject: kernel panic, qdisc_dequeue_head, htb, 4.7.0-rc7
Date: Sun, 24 Jul 2016 20:56:26 +0300
Message-ID: <3e85e4ac67d0a104a9585cfca302883e@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:49340 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752010AbcGXR4a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 Jul 2016 13:56:30 -0400
Received: from localhost (localhost [127.0.0.1])
	by nuclearcat.com (Postfix) with ESMTP id 2C40A67C002E
	for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 17:56:28 +0000 (UTC)
Received: from nuclearcat.com ([127.0.0.1])
	by localhost (nuclearcat.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Ryp6ITC6-f0Z for <netdev@vger.kernel.org>;
	Sun, 24 Jul 2016 17:56:26 +0000 (UTC)
Received: from germany.nuclearcat.com (localhost [127.0.0.1])
	(Authenticated sender: nuclearcat@nuclearcat.com)
	by nuclearcat.com (Postfix) with ESMTPA id 8E12C67C002C
	for <netdev@vger.kernel.org>; Sun, 24 Jul 2016 17:56:26 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm still struggling to find out reason of random reboots on BRAS 
servers (PPPoE + HTB egress on ppp and policer for ppp ingress).
Here is happening at 4.7.0-rc7, it seems panic is happening at peak 
time, 1-2 times per day now. I noticed also rise of kernel panic on 
other locations as well, but i'm still setting up netconsole there.

Here is panic message:
[71623.328457] general protection fault: 0000 [#1] SMP
[71623.328658] Modules linked in:
cls_fw
act_police
cls_u32
sch_ingress
sch_sfq
sch_htb
netconsole
configfs
coretemp
nf_nat_pptp
nf_nat_proto_gre
nf_conntrack_pptp
nf_conntrack_proto_gre
pppoe
pppox
ppp_generic
slhc
tun
xt_REDIRECT
nf_nat_redirect
xt_TCPMSS
ipt_REJECT
nf_reject_ipv4
xt_set
ts_bm
xt_string
xt_connmark
xt_DSCP
xt_mark
xt_tcpudp
ip_set_hash_net
ip_set_hash_ip
ip_set
nfnetlink
iptable_mangle
iptable_filter
iptable_nat
nf_conntrack_ipv4
nf_defrag_ipv4
nf_nat_ipv4
nf_nat
nf_conntrack
ip_tables
x_tables
8021q
garp
mrp
stp
llc

[71623.332554] CPU: 0 PID: 0 Comm: swapper/0 Not tainted 
4.7.0-rc7-build-0107 #2
[71623.332754] Hardware name: HP ProLiant DL320e Gen8 v2, BIOS P80 
04/02/2015
[71623.332954] task: ffffffff8200b500 ti: ffffffff82000000 task.ti: 
ffffffff82000000
[71623.333289] RIP: 0010:[<ffffffff81881e25>]
[<ffffffff81881e25>] qdisc_dequeue_head+0x5a/0x7b
[71623.333685] RSP: 0018:ffff880447403e10  EFLAGS: 00010282
[71623.333882] RAX: ffff880427b67f00 RBX: 00004125c7ec4a6c RCX: 
0000000000000001
[71623.334083] RDX: ffa0050402791340 RSI: 0000000000000000 RDI: 
ffff8804164f2000
[71623.334281] RBP: ffff880447403e10 R08: 0000000000000000 R09: 
ffff880425471868
[71623.334481] R10: ffffffff820050c0 R11: 0000000000000001 R12: 
0000000000000007
[71623.334680] R13: ffff880425471000 R14: 0000000000000000 R15: 
ffff88040d9ebc00
[71623.334881] FS:  0000000000000000(0000) GS:ffff880447400000(0000) 
knlGS:0000000000000000
[71623.335216] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[71623.335415] CR2: 00007f184bb2f730 CR3: 0000000002006000 CR4: 
00000000001406f0
[71623.335614] Stack:
[71623.335808]  ffff880447403eb0
ffffffffa01328af
0000000000000578
00000000000001a0

[71623.336369]  000000010440678b
ffff880425471140
0000000700000001
ffff880425471860

[71623.336929]  ffff880425471868
fffffffe00000000
0000000000000000
ffff88040d9ebc00

[71623.340797] Call Trace:
[71623.340987]  <IRQ>

[71623.341050]  [<ffffffffa01328af>] htb_dequeue+0x33a/0x6fe [sch_htb]
[71623.341433]  [<ffffffff8187bdbb>] __qdisc_run+0x9d/0x17b
[71623.341630]  [<ffffffff811000d5>] ? ktime_get+0x4b/0x9a
[71623.341827]  [<ffffffff8185ce32>] net_tx_action+0xe3/0x148
[71623.342027]  [<ffffffff810c46e0>] __do_softirq+0xb9/0x1a9
[71623.342226]  [<ffffffff810c4917>] irq_exit+0x37/0x7c
[71623.342425]  [<ffffffff8102b8c6>] smp_apic_timer_interrupt+0x3d/0x48
[71623.342627]  [<ffffffff818db01c>] apic_timer_interrupt+0x7c/0x90
[71623.342825]  <EOI>

[71623.342887]  [<ffffffff8101bccb>] ? mwait_idle+0x64/0x7a
[71623.343276]  [<ffffffff810d7f11>] ? 
atomic_notifier_call_chain+0x13/0x15
[71623.343476]  [<ffffffff8101c0c5>] arch_cpu_idle+0xa/0xc
[71623.343675]  [<ffffffff810eaef0>] default_idle_call+0x27/0x29
[71623.343872]  [<ffffffff810eb007>] cpu_startup_entry+0x115/0x1bf
[71623.344072]  [<ffffffff818d650b>] rest_init+0x72/0x74
[71623.344270]  [<ffffffff820cfde5>] start_kernel+0x3bc/0x3c9
[71623.344467]  [<ffffffff820cf40c>] x86_64_start_reservations+0x2f/0x31
[71623.344668]  [<ffffffff820cf4c9>] x86_64_start_kernel+0xbb/0xbe
[71623.344867] Code:
00
48
c7
40
08
00
00
00
00
48
89
51
08
48
89
0a
8b
50
28
b9
01
00
00
00
29
97
c4
00
00
00
8b
90
c0
00
00
00
48
03
90
c8
00
00
00

83
7a
02
00
74
04
0f
b7
4a
04
8b
50
28
01
8f
b8
00
00
00
48

[71623.349025] RIP
[<ffffffff81881e25>] qdisc_dequeue_head+0x5a/0x7b
[71623.349281]  RSP <ffff880447403e10>
[71623.349500] ---[ end trace 0fb7352fcf43439e ]---
[71623.355886] Kernel panic - not syncing: Fatal exception in interrupt
[71623.356093] Kernel Offset: disabled
[71623.359937] ERST: [Firmware Warn]: Firmware does not respond in time.
[71623.388538] Rebooting in 5 seconds.
