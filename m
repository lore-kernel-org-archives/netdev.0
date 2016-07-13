From: nuclearcat@nuclearcat.com
Subject: 4.6.3 panic on nf_ct_delete (nf_conntrack)
Date: Wed, 13 Jul 2016 23:06:47 +0300
Message-ID: <df376f88504cb0f20b20acf42962c16d@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:32830 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751326AbcGMUHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 16:07:01 -0400
Received: from localhost (localhost [127.0.0.1])
	by nuclearcat.com (Postfix) with ESMTP id 1674967C0115
	for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 20:06:49 +0000 (UTC)
Received: from nuclearcat.com ([127.0.0.1])
	by localhost (nuclearcat.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Nk3Nq4ngxW2O for <netdev@vger.kernel.org>;
	Wed, 13 Jul 2016 20:06:47 +0000 (UTC)
Received: from germany.nuclearcat.com (localhost [127.0.0.1])
	(Authenticated sender: nuclearcat@nuclearcat.com)
	by nuclearcat.com (Postfix) with ESMTPA id 4A8B667C0110
	for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 20:06:47 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Workload: pppoe server, 5k users on ppp interfaces. No actual SNAT/DNAT, 
but using connmark and REDIRECT

[176412.990104] general protection fault: 0000 [#1]
SMP

[176412.990424] Modules linked in:
sch_pie
cls_fw
act_police
cls_u32
sch_ingress
sch_sfq
sch_htb
netconsole

[176412.991427]  configfs
coretemp
nf_nat_pptp
nf_nat_proto_gre
nf_conntrack_pptp
nf_conntrack_proto_gre
pppoe
pppox

[176412.992571]  ppp_generic
slhc

[176412.993218]  tun
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

[176412.996208]  garp
mrp
stp
llc

[176412.996834] CPU: 5 PID: 0 Comm: swapper/5 Not tainted 
4.6.3-build-0105 #4
[176412.997037] Hardware name: HP ProLiant DL320e Gen8 v2, BIOS P80 
04/02/2015
[176412.997241] task: ffff88043558af00 ti: ffff8804355a0000 task.ti: 
ffff8804355a0000
[176412.997580] RIP: 0010:[<ffffffffa003d0f7>]
[<ffffffffa003d0f7>] nf_ct_delete+0x26/0x1dc [nf_conntrack]
[176412.997985] RSP: 0018:ffff8804474a3e80  EFLAGS: 00010282
[176412.998187] RAX: ffff880428bc0c90 RBX: ffac050402505080 RCX: 
dead000000000200
[176412.998524] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
ffff880428bc0c08
[176412.998865] RBP: ffff8804474a3ec8 R08: ffff8804474a3f08 R09: 
0000000000000000
[176412.999204] R10: ffffffff820050c0 R11: 000000000000049a R12: 
ffff880428bc0c08
[176412.999545] R13: 0000000000000000 R14: 0000000000000000 R15: 
ffffffff820050c8
[176412.999885] FS:  0000000000000000(0000) GS:ffff8804474a0000(0000) 
knlGS:0000000000000000
[176413.000226] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[176413.000427] CR2: 00007f1dc4960100 CR3: 0000000002006000 CR4: 
00000000001406e0
[176413.000767] Stack:
[176413.000963]  ffff8804474a3ec0
ffffffff810fb036
ffff88043558af07
ffff8804474adcc0

[176413.001534]  0000000080000100
ffffffffa003d2ad
00000000000000a1
ffff8804355a4000

[176413.002097]  ffffffff820050c8
ffff8804474a3ed8
ffffffffa003d2ba
ffff8804474a3ef8

[176413.002666] Call Trace:
[176413.002862]  <IRQ>

[176413.002926]  [<ffffffff810fb036>] ? hrtimer_forward+0xd5/0xeb
[176413.003322]  [<ffffffffa003d2ad>] ? nf_ct_delete+0x1dc/0x1dc 
[nf_conntrack]
[176413.003525]  [<ffffffffa003d2ba>] death_by_timeout+0xd/0xf 
[nf_conntrack]
[176413.003727]  [<ffffffff810fa823>] call_timer_fn.isra.26+0x17/0x6d
[176413.003931]  [<ffffffff810fa9ef>] run_timer_softirq+0x176/0x197
[176413.004134]  [<ffffffff810c401a>] __do_softirq+0xb9/0x1a9
[176413.004333]  [<ffffffff810c4251>] irq_exit+0x37/0x7c
[176413.004533]  [<ffffffff8102b8f7>] smp_apic_timer_interrupt+0x3d/0x48
[176413.004734]  [<ffffffff818cb15c>] apic_timer_interrupt+0x7c/0x90
[176413.004935]  <EOI>

[176413.004997]  [<ffffffff8101be12>] ? mwait_idle+0x68/0x7e
[176413.005391]  [<ffffffff8101c212>] arch_cpu_idle+0xa/0xc
[176413.005592]  [<ffffffff810ea333>] default_idle_call+0x27/0x29
[176413.005791]  [<ffffffff810ea44a>] cpu_startup_entry+0x115/0x1bf
[176413.005993]  [<ffffffff8102a289>] start_secondary+0xf1/0xf4
[176413.006193] Code:
5e
41
5f
5d
c3
55
48
89
e5
41
57
41
56
41
55
41
54
41
89
f5
53
49
89
fc
41
89
d6
48
83
ec
20
48
8b
9f
c8
00
00
00
48
85
db
74
20
b7
43
1c
66
85
c0
74
17
48
01
c3
74
12
48
83
7b
08
00
75
0b

[176413.010382] RIP
[<ffffffffa003d0f7>] nf_ct_delete+0x26/0x1dc [nf_conntrack]
[176413.010643]  RSP <ffff8804474a3e80>
[176413.010855] ---[ end trace cf1060fc5087293e ]---
[176413.018573] Kernel panic - not syncing: Fatal exception in interrupt
[176413.018781] Kernel Offset: disabled
[176413.046284] ERST: [Firmware Warn]: Firmware does not respond in 
time.
[176413.050041] Rebooting in 5 seconds..
