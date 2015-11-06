From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: 4.3.0, neighbour: arp_cache: neighbor table overflow! and panic
Date: Fri, 06 Nov 2015 20:42:57 +0200
Message-ID: <c641087ae3e5cbcf707e48677b5fbd21@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:45405 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbbKFSnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 13:43:06 -0500
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 7E123488A7E
	for <netdev@vger.kernel.org>; Fri,  6 Nov 2015 20:43:00 +0200 (EET)
Received: from webmail.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id 3DEB6488A7E
	for <netdev@vger.kernel.org>; Fri,  6 Nov 2015 20:42:57 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I have several pppoe servers running under older kernels, and upgraded 
two of them to 4.3.0
After that, one of them randomly rebooting and stacktrace always 
different. Also i noticed message appearing, that didnt exist before on 
older kernels, appearing on both now:
"neighbour: arp_cache: neighbor table overflow!"

At ip neigh i didnt noticed anything suspicious, there is less than 10 
entries, but there is quite a lot arp requests on eth0 (irrelevant to 
this host), that may cause some issues.

Here is panic messages caught over netconsole:

<r> [151784.835507] general protection fault: 0000 [#1]
<r> SMP
<r>
<r> [151784.836049] Modules linked in:
<r> act_skbedit
<r> sch_fq
<r> cls_fw
<r> act_police
<r> cls_u32
<r> sch_ingress
<r> sch_sfq
<r> sch_htb
<r> netconsole
<r> configfs
<r> pppoe
<r> pppox
<r> ppp_generic
<r> slhc
<r> xt_nat
<r> ts_bm
<r> xt_string
<r> xt_connmark
<r> xt_TCPMSS
<r> xt_tcpudp
<r> xt_mark
<r> iptable_filter
<r> iptable_nat
<r> nf_conntrack_ipv4
<r> nf_defrag_ipv4
<r> nf_nat_ipv4
<r> nf_nat
<r> nf_conntrack
<r> iptable_mangle
<r> ip_tables
<r> x_tables
<r> 8021q
<r> garp
<r> mrp
<r> stp
<r> llc
<r>
<r> [151784.840667] CPU: 21 PID: 0 Comm: swapper/21 Not tainted 
4.3.0-build-0087 #3
<r> [151784.841014] Hardware name: Intel Corporation S2600GZ/S2600GZ, 
BIOS SE5C600.86B.01.03.0002.062020121504 06/20/2012
<r> [151784.841575] task: ffff88042d29dc00 ti: ffff88042d2c4000 task.ti: 
ffff88042d2c4000
<r> [151784.847603] RIP: 0010:[<ffffffffa004519a>]
<r> [<ffffffffa004519a>] nf_ct_delete+0x28/0x20e [nf_conntrack]
<r> [151784.848421] RSP: 0018:ffff88042f0a3e80  EFLAGS: 00010246
<r> [151784.848797] RAX: ffa2050402d3ab00 RBX: ffff8803d5087368 RCX: 
dead000000000200
<r> [151784.849421] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 
ffff8803d5087368
<r> [151784.850090] RBP: ffff88042f0a3ec8 R08: ffff88042f0a3f08 R09: 
0000000000000100
<r> [151784.850736] R10: 0000000000002710 R11: 0000000000000020 R12: 
ffffffffa0045380
<r> [151784.851389] R13: 0000000000000065 R14: 0000000000000000 R15: 
0000000000000000
<r> [151784.852096] FS:  0000000000000000(0000) 
GS:ffff88042f0a0000(0000) knlGS:0000000000000000
<r> [151784.852791] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<r> [151784.853204] CR2: 00007fec804efcbc CR3: 000000000200c000 CR4: 
00000000000406e0
<r> [151784.853752] Stack:
<r> [151784.854110]  ffff88042b074400
<r> 00001f3c94e2cf92
<r> 0001144267c3b61c
<r> 0000172f18fced27
<r>
<r> [151784.855136]  0000000080000100
<r> ffffffffa0045380
<r> 0000000000000065
<r> ffff88042d2c8000
<r>
<r> [151784.856203]  0000000000000100
<r> ffff88042f0a3ed8
<r> ffffffffa004538d
<r> ffff88042f0a3ef8
<r>
<r> [151784.857224] Call Trace:
<r> [151784.857608]  <IRQ>
<r>
<r> [151784.857717]  [<ffffffffa0045380>] ? nf_ct_delete+0x20e/0x20e 
[nf_conntrack]
<r> [151784.858432]  [<ffffffffa004538d>] death_by_timeout+0xd/0xf 
[nf_conntrack]
<r> [151784.858807]  [<ffffffff810f4db8>] 
call_timer_fn.isra.26+0x17/0x6d
<r> [151784.859238]  [<ffffffff810f4f80>] run_timer_softirq+0x172/0x193
<r> [151784.859630]  [<ffffffff810c0588>] __do_softirq+0xba/0x1a9
<r> [151784.859985]  [<ffffffff810c07bf>] irq_exit+0x37/0x7c
<r> [151784.860380]  [<ffffffff81029c06>] 
smp_apic_timer_interrupt+0x3d/0x48
<r> [151784.860774]  [<ffffffff818cdccc>] apic_timer_interrupt+0x7c/0x90
<r> [151784.861144]  <EOI>
<r>
<r> [151784.861272]  [<ffffffff8100aed5>] ? mwait_idle+0x68/0x7e
<r> [151784.862033]  [<ffffffff810d3506>] ? 
atomic_notifier_call_chain+0x13/0x15
<r> [151784.862409]  [<ffffffff8100b2d8>] arch_cpu_idle+0xa/0xc
<r> [151784.862754]  [<ffffffff810e5822>] default_idle_call+0x27/0x29
<r> [151784.863127]  [<ffffffff810e5945>] cpu_startup_entry+0x121/0x1da
<r> [151784.863518]  [<ffffffff810286c9>] start_secondary+0xe7/0xea
<r> [151784.863893] Code:
<r> 5f
<r> 5d
<r> c3
<r> 55
<r> 48
<r> 89
<r> e5
<r> 41
<r> 57
<r> 41
<r> 89
<r> d7
<r> 41
<r> 56
<r> 41
<r> 89
<r> f6
<r> 41
<r> 55
<r> 41
<r> 54
<r> 53
<r> 48
<r> 89
<r> fb
<r> 48
<r> 83
<r> ec
<r> 20
<r> 48
<r> 8b
<r> 87
<r> c8
<r> 00
<r> 00
<r> 00
<r> 48
<r> 85
<r> c0
<r> 74
<r> 0c
<r> 31
<r> d2
<r>
<r> 83
<r> 78
<r> 1c
<r> 00
<r> 0f
<r> 95
<r> c2
<r> eb
<r> 02
<r> 31
<r> d2
<r> 85
<r> d2
<r> 74
<r> 1e
<r> 44
<r> 0f
<r> b7
<r> 60
<r> 1c
<r>
<r> [151784.871213] RIP
<r> [<ffffffffa004519a>] nf_ct_delete+0x28/0x20e [nf_conntrack]
<r> [151784.871692]  RSP <ffff88042f0a3e80>
<r> [151784.872062] ---[ end trace 54f9b78db1dfe968 ]---
<r> [151784.886584] Kernel panic - not syncing: Fatal exception in 
interrupt
<r> [151784.886981] Kernel Offset: disabled
<r> [151784.922664] Rebooting in 5 seconds..


<r2> 10.0.253.10 [ 1722.079874] general protection fault: 0000 [#1]
<r2> 10.0.253.10 SMP
<r2> 10.0.253.10
<r2> 10.0.253.10 [ 1722.080366] Modules linked in:
<r2> 10.0.253.10 act_skbedit
<r2> 10.0.253.10 sch_fq
<r2> 10.0.253.10 cls_fw
<r2> 10.0.253.10 act_police
<r2> 10.0.253.10 cls_u32
<r2> 10.0.253.10 sch_ingress
<r2> 10.0.253.10 sch_sfq
<r2> 10.0.253.10 sch_htb
<r2> 10.0.253.10 netconsole
<r2> 10.0.253.10 configfs
<r2> 10.0.253.10 pppoe
<r2> 10.0.253.10 pppox
<r2> 10.0.253.10 ppp_generic
<r2> 10.0.253.10 slhc
<r2> 10.0.253.10 xt_nat
<r2> 10.0.253.10 ts_bm
<r2> 10.0.253.10 xt_string
<r2> 10.0.253.10 xt_connmark
<r2> 10.0.253.10 xt_TCPMSS
<r2> 10.0.253.10 xt_tcpudp
<r2> 10.0.253.10 xt_mark
<r2> 10.0.253.10 iptable_filter
<r2> 10.0.253.10 iptable_nat
<r2> 10.0.253.10 nf_conntrack_ipv4
<r2> 10.0.253.10 nf_defrag_ipv4
<r2> 10.0.253.10 nf_nat_ipv4
<r2> 10.0.253.10 nf_nat
<r2> 10.0.253.10 nf_conntrack
<r2> 10.0.253.10 iptable_mangle
<r2> 10.0.253.10 ip_tables
<r2> 10.0.253.10 x_tables
<r2> 10.0.253.10 8021q
<r2> 10.0.253.10 garp
<r2> 10.0.253.10 mrp
<r2> 10.0.253.10 stp
<r2> 10.0.253.10 llc
<r2> 10.0.253.10
<r2> 10.0.253.10 [ 1722.085568] CPU: 19 PID: 103 Comm: ksoftirqd/19 Not 
tainted 4.3.0-build-0087 #3
<r2> 10.0.253.10 [ 1722.086291] Hardware name: Intel Corporation 
S2600GZ/S2600GZ, BIOS SE5C600.86B.01.03.0002.062020121504 06/20/2012
<r2> 10.0.253.10 [ 1722.087011] task: ffff88042cee0000 ti: 
ffff88042cee8000 task.ti: ffff88042cee8000
<r2> 10.0.253.10 [ 1722.087694] RIP: 0010:[<ffffffffa004511d>]
<r2> 10.0.253.10 [<ffffffffa004511d>] nf_ct_delete_from_lists+0xa9/0xfe 
[nf_conntrack]
<r2> 10.0.253.10 [ 1722.088500] RSP: 0018:ffff88042ceebd48  EFLAGS: 
00010246
<r2> 10.0.253.10 [ 1722.088863] RAX: ffa205040222b180 RBX: 
ffff8803f29177c8 RCX: 00000000d730b83f
<r2> 10.0.253.10 [ 1722.089258] RDX: ffff8804245873c0 RSI: 
0000000000010e78 RDI: ffffffffa00522a0
<r2> 10.0.253.10 [ 1722.089626] RBP: ffff88042ceebd78 R08: 
0000000000123689 R09: 00000000cb00b5fc
<r2> 10.0.253.10 [ 1722.089990] R10: ffff8803f2917838 R11: 
ffff8803f3cc36f0 R12: 000000000000a7a8
<r2> 10.0.253.10 [ 1722.090403] R13: 000000000000a7a8 R14: 
0000000000010e78 R15: ffff8803f29177e8
<r2> 10.0.253.10 [ 1722.090788] FS:  0000000000000000(0000) 
GS:ffff88042f060000(0000) knlGS:0000000000000000
<r2> 10.0.253.10 [ 1722.091453] CS:  0010 DS: 0000 ES: 0000 CR0: 
0000000080050033
<r2> 10.0.253.10 [ 1722.091806] CR2: 00007f5b144231e3 CR3: 
00000000b6308000 CR4: 00000000000406e0
<r2> 10.0.253.10 [ 1722.092220] Stack:
<r2> 10.0.253.10 [ 1722.092584]  0000000200000000
<r2> 10.0.253.10 ffff8803f29177c8
<r2> 10.0.253.10 ffffffffa0045380
<r2> 10.0.253.10 0000000000000000
<r2> 10.0.253.10
<r2> 10.0.253.10 [ 1722.093546]  0000000000000000
<r2> 10.0.253.10 0000000000000000
<r2> 10.0.253.10 ffff88042ceebdd0
<r2> 10.0.253.10 ffffffffa0045359
<r2> 10.0.253.10
<r2> 10.0.253.10 [ 1722.094499]  ffff88042ceebe00
<r2> 10.0.253.10 ffffffff810deb4a
<r2> 10.0.253.10 0000000000000202
<r2> 10.0.253.10 ffff88042ceebdd0
<r2> 10.0.253.10
<r2> 10.0.253.10 [ 1722.095399] Call Trace:
<r2> 10.0.253.10 [ 1722.095720]  [<ffffffffa0045380>] ? 
nf_ct_delete+0x20e/0x20e [nf_conntrack]
<r2> 10.0.253.10 [ 1722.096063]  [<ffffffffa0045359>] 
nf_ct_delete+0x1e7/0x20e [nf_conntrack]
<r2> 10.0.253.10 [ 1722.096412]  [<ffffffff810deb4a>] ? 
dequeue_task_fair+0x687/0x696
<r2> 10.0.253.10 [ 1722.096748]  [<ffffffffa0045380>] ? 
nf_ct_delete+0x20e/0x20e [nf_conntrack]
<r2> 10.0.253.10 [ 1722.097105]  [<ffffffffa004538d>] 
death_by_timeout+0xd/0xf [nf_conntrack]
<r2> 10.0.253.10 [ 1722.097454]  [<ffffffff810f4db8>] 
call_timer_fn.isra.26+0x17/0x6d
<r2> 10.0.253.10 [ 1722.097796]  [<ffffffff810f4f80>] 
run_timer_softirq+0x172/0x193
<r2> 10.0.253.10 [ 1722.098136]  [<ffffffff810c0588>] 
__do_softirq+0xba/0x1a9
<r2> 10.0.253.10 [ 1722.098473]  [<ffffffff810c068c>] 
run_ksoftirqd+0x15/0x2a
<r2> 10.0.253.10 [ 1722.098822]  [<ffffffff810d4d21>] 
smpboot_thread_fn+0x126/0x13d
<r2> 10.0.253.10 [ 1722.099182]  [<ffffffff810d4bfb>] ? 
sort_range+0x1d/0x1d
<r2> 10.0.253.10 [ 1722.099522]  [<ffffffff810d2aa5>] kthread+0xcd/0xd5
<r2> 10.0.253.10 [ 1722.099873]  [<ffffffff810d29d8>] ? 
kthread_create_on_node+0x159/0x159
<r2> 10.0.253.10 [ 1722.100207]  [<ffffffff818cd36f>] 
ret_from_fork+0x3f/0x70
<r2> 10.0.253.10 [ 1722.100540]  [<ffffffff810d29d8>] ? 
kthread_create_on_node+0x159/0x159
<r2> 10.0.253.10 [ 1722.100883] Code:
<r2> 10.0.253.10 8b
<r2> 10.0.253.10 53
<r2> 10.0.253.10 18
<r2> 10.0.253.10 a8
<r2> 10.0.253.10 01
<r2> 10.0.253.10 48
<r2> 10.0.253.10 89
<r2> 10.0.253.10 02
<r2> 10.0.253.10 75
<r2> 10.0.253.10 04
<r2> 10.0.253.10 48
<r2> 10.0.253.10 89
<r2> 10.0.253.10 50
<r2> 10.0.253.10 08
<r2> 10.0.253.10 48
<r2> 10.0.253.10 b8
<r2> 10.0.253.10 00
<r2> 10.0.253.10 02
<r2> 10.0.253.10 00
<r2> 10.0.253.10 00
<r2> 10.0.253.10 00
<r2> 10.0.253.10 00
<r2> 10.0.253.10 ad
<r2> 10.0.253.10 de
<r2> 10.0.253.10 48
<r2> 10.0.253.10 8b
<r2> 10.0.253.10 53
<r2> 10.0.253.10 50
<r2> 10.0.253.10 48
<r2> 10.0.253.10 89
<r2> 10.0.253.10 43
<r2> 10.0.253.10 18
<r2> 10.0.253.10 48
<r2> 10.0.253.10 8b
<r2> 10.0.253.10 43
<r2> 10.0.253.10 48
<r2> 10.0.253.10 a8
<r2> 10.0.253.10 01
<r2> 10.0.253.10 48
<r2> 10.0.253.10 89
<r2> 10.0.253.10 02
<r2> 10.0.253.10 75
<r2> 10.0.253.10 04
<r2> 10.0.253.10
<r2> 10.0.253.10 89
<r2> 10.0.253.10 50
<r2> 10.0.253.10 08
<r2> 10.0.253.10 48
<r2> 10.0.253.10 b8
<r2> 10.0.253.10 00
<r2> 10.0.253.10 02
<r2> 10.0.253.10 00
<r2> 10.0.253.10 00
<r2> 10.0.253.10 00
<r2> 10.0.253.10 00
<r2> 10.0.253.10 ad
<r2> 10.0.253.10 de
<r2> 10.0.253.10 48
<r2> 10.0.253.10 89
<r2> 10.0.253.10 df
<r2> 10.0.253.10 48
<r2> 10.0.253.10 89
<r2> 10.0.253.10 43
<r2> 10.0.253.10 50
<r2> 10.0.253.10
<r2> 10.0.253.10 [ 1722.107756] RIP
<r2> 10.0.253.10 [<ffffffffa004511d>] nf_ct_delete_from_lists+0xa9/0xfe 
[nf_conntrack]
<r2> 10.0.253.10 [ 1722.108524]  RSP <ffff88042ceebd48>
<r2> 10.0.253.10 [ 1722.108929] ---[ end trace ff9c8cc3b1db9a20 ]---
<r2> 10.0.253.10 [ 1722.120632] Kernel panic - not syncing: Fatal 
exception in interrupt
<r2> 10.0.253.10 [ 1722.121002] Kernel Offset: disabled
<r2> 10.0.253.10 [ 1722.147803] Rebooting in 5 seconds..

<r3> 10.0.253.10 [30436.178360] general protection fault: 0000 [#1]
<r3> 10.0.253.10 SMP
<r3> 10.0.253.10
<r3> 10.0.253.10 [30436.178886] Modules linked in:
<r3> 10.0.253.10 act_skbedit
<r3> 10.0.253.10 sch_fq
<r3> 10.0.253.10 cls_fw
<r3> 10.0.253.10 act_police
<r3> 10.0.253.10 cls_u32
<r3> 10.0.253.10 sch_ingress
<r3> 10.0.253.10 sch_sfq
<r3> 10.0.253.10 sch_htb
<r3> 10.0.253.10 netconsole
<r3> 10.0.253.10 configfs
<r3> 10.0.253.10 pppoe
<r3> 10.0.253.10 pppox
<r3> 10.0.253.10 ppp_generic
<r3> 10.0.253.10 slhc
<r3> 10.0.253.10 xt_nat
<r3> 10.0.253.10 ts_bm
<r3> 10.0.253.10 xt_string
<r3> 10.0.253.10 xt_connmark
<r3> 10.0.253.10 xt_TCPMSS
<r3> 10.0.253.10 xt_tcpudp
<r3> 10.0.253.10 xt_mark
<r3> 10.0.253.10 iptable_filter
<r3> 10.0.253.10 iptable_nat
<r3> 10.0.253.10 nf_conntrack_ipv4
<r3> 10.0.253.10 nf_defrag_ipv4
<r3> 10.0.253.10 nf_nat_ipv4
<r3> 10.0.253.10 nf_nat
<r3> 10.0.253.10 nf_conntrack
<r3> 10.0.253.10 iptable_mangle
<r3> 10.0.253.10 ip_tables
<r3> 10.0.253.10 x_tables
<r3> 10.0.253.10 8021q
<r3> 10.0.253.10 garp
<r3> 10.0.253.10 mrp
<r3> 10.0.253.10 stp
<r3> 10.0.253.10 llc
<r3> 10.0.253.10
<r3> 10.0.253.10 [30436.183242] CPU: 20 PID: 0 Comm: swapper/20 Not 
tainted 4.2.3-build-0087 #3
<r3> 10.0.253.10 [30436.183559] Hardware name: Intel Corporation 
S2600GZ/S2600GZ, BIOS SE5C600.86B.01.03.0002.062020121504 06/20/2012
<r3> 10.0.253.10 [30436.184090] task: ffff88042d29d080 ti: 
ffff88042d2c0000 task.ti: ffff88042d2c0000
<r3> 10.0.253.10 [30436.184611] RIP: 0010:[<ffffffffa0046340>]
<r3> 10.0.253.10 [<ffffffffa0046340>] 
nf_conntrack_tuple_taken+0x7d/0x199 [nf_conntrack]
<r3> 10.0.253.10 [30436.185243] RSP: 0018:ffff88042f083a78  EFLAGS: 
00010246
<r3> 10.0.253.10 [30436.185569] RAX: ffa2050402d7d078 RBX: 
ffff88042f083ab0 RCX: 000060fbd0804910
<r3> 10.0.253.10 [30436.185919] RDX: 0000000000000000 RSI: 
ffff8800a752b368 RDI: 0000000000000000
<r3> 10.0.253.10 [30436.186253] RBP: ffff88042f083a98 R08: 
000000008eb30a31 R09: 000000001f97122f
<r3> 10.0.253.10 [30436.186595] R10: ffff88042f083ac8 R11: 
00000000fffffffe R12: 0000000000000000
<r3> 10.0.253.10 [30436.186947] R13: ffff8803f01e0348 R14: 
0000000000020000 R15: 0000000000000001
<r3> 10.0.253.10 [30436.187260] FS:  0000000000000000(0000) 
GS:ffff88042f080000(0000) knlGS:0000000000000000
<r3> 10.0.253.10 [30436.187846] CS:  0010 DS: 0000 ES: 0000 CR0: 
0000000080050033
<r3> 10.0.253.10 [30436.188221] CR2: 00007f7e15ed637c CR3: 
000000042ab29000 CR4: 00000000000406e0
<r3> 10.0.253.10 [30436.188570] Stack:
<r3> 10.0.253.10 [30436.188931]  ffff8803f01e0348
<r3> 10.0.253.10 ffff88042f083b48
<r3> 10.0.253.10 0000000000000000
<r3> 10.0.253.10 ffff88042f083be0
<r3> 10.0.253.10
<r3> 10.0.253.10 [30436.189921]  ffff88042f083ae8
<r3> 10.0.253.10 ffffffffa00671fe
<r3> 10.0.253.10 ffff8803f01e0348
<r3> 10.0.253.10 000000000105f0ad
<r3> 10.0.253.10
<r3> 10.0.253.10 [30436.190973]  0000000000000000
<r3> 10.0.253.10 9f3013ac00025000
<r3> 10.0.253.10 0000000000000000
<r3> 10.0.253.10 01069c6e00000000
<r3> 10.0.253.10
<r3> 10.0.253.10 [30436.191993] Call Trace:
<r3> 10.0.253.10 [30436.192387]  <IRQ>
<r3> 10.0.253.10
<r3> 10.0.253.10 [30436.192507]  [<ffffffffa00671fe>] 
nf_nat_used_tuple+0x24/0x2b [nf_nat]
<r3> 10.0.253.10 [30436.193247]  [<ffffffffa0067aa7>] 
nf_nat_setup_info+0x366/0x7b3 [nf_nat]
<r3> 10.0.253.10 [30436.193650]  [<ffffffffa004cec4>] ? 
tcp_packet+0xc4a/0xd1e [nf_conntrack]
<r3> 10.0.253.10 [30436.194038]  [<ffffffffa0067f47>] 
__nf_nat_alloc_null_binding+0x53/0x55 [nf_nat]
<r3> 10.0.253.10 [30436.194733]  [<ffffffffa0067f65>] 
nf_nat_alloc_null_binding+0x1c/0x1e [nf_nat]
<r3> 10.0.253.10 [30436.195355]  [<ffffffffa007266e>] 
nf_nat_ipv4_fn+0x142/0x19c [nf_nat_ipv4]
<r3> 10.0.253.10 [30436.195705]  [<ffffffffa008b012>] ? 
iptable_nat_ipv4_fn+0x12/0x12 [iptable_nat]
<r3> 10.0.253.10 [30436.196293]  [<ffffffffa00726f1>] 
nf_nat_ipv4_in+0x29/0x72 [nf_nat_ipv4]
<r3> 10.0.253.10 [30436.196645]  [<ffffffffa008b061>] 
iptable_nat_ipv4_in+0x10/0x12 [iptable_nat]
<r3> 10.0.253.10 [30436.196994]  [<ffffffff818442f0>] 
nf_iterate+0x4d/0x69
<r3> 10.0.253.10 [30436.197358]  [<ffffffff8184433a>] 
nf_hook_slow+0x2e/0x9f
<r3> 10.0.253.10 [30436.197728]  [<ffffffff81849635>] ip_rcv+0x302/0x312
<r3> 10.0.253.10 [30436.198071]  [<ffffffff81848f26>] ? 
ip_local_deliver_finish+0x19c/0x19c
<r3> 10.0.253.10 [30436.198452]  [<ffffffff8181c813>] 
__netif_receive_skb_core+0x645/0x7b4
<r3> 10.0.253.10 [30436.198798]  [<ffffffffa00de8f8>] ? 
htb_dequeue+0x410/0x70f [sch_htb]
<r3> 10.0.253.10 [30436.199138]  [<ffffffff8181d1b8>] 
__netif_receive_skb+0x13/0x55
<r3> 10.0.253.10 [30436.199476]  [<ffffffff8181de31>] 
process_backlog+0x91/0x111
<r3> 10.0.253.10 [30436.199827]  [<ffffffff810bf7ca>] ? 
irq_exit+0x7a/0x7c
<r3> 10.0.253.10 [30436.200142]  [<ffffffff8181dc44>] 
net_rx_action+0xf9/0x255
<r3> 10.0.253.10 [30436.200509]  [<ffffffff810bf54c>] 
__do_softirq+0xb9/0x1a8
<r3> 10.0.253.10 [30436.200822]  [<ffffffff810bf787>] irq_exit+0x37/0x7c
<r3> 10.0.253.10 [30436.201147]  [<ffffffff81028010>] 
smp_call_function_single_interrupt+0x2e/0x30
<r3> 10.0.253.10 [30436.201700]  [<ffffffff818a6915>] 
call_function_single_interrupt+0x65/0x70
<r3> 10.0.253.10 [30436.202059]  <EOI>
<r3> 10.0.253.10
<r3> 10.0.253.10 [30436.202150]  [<ffffffff8100ae89>] ? 
mwait_idle+0x68/0x7e
<r3> 10.0.253.10 [30436.202811]  [<ffffffff810d263e>] ? 
atomic_notifier_call_chain+0x13/0x15
<r3> 10.0.253.10 [30436.203152]  [<ffffffff8100b28b>] 
arch_cpu_idle+0xa/0xc
<r3> 10.0.253.10 [30436.203504]  [<ffffffff810e337b>] 
default_idle_call+0x27/0x29
<r3> 10.0.253.10 [30436.203831]  [<ffffffff810e349e>] 
cpu_startup_entry+0x121/0x1da
<r3> 10.0.253.10 [30436.204180]  [<ffffffff8102868e>] 
start_secondary+0xfc/0x11a
<r3> 10.0.253.10 [30436.204506] Code:
<r3> 10.0.253.10 89
<r3> 10.0.253.10 c0
<r3> 10.0.253.10 65
<r3> 10.0.253.10 81
<r3> 10.0.253.10 05
<r3> 10.0.253.10 e6
<r3> 10.0.253.10 44
<r3> 10.0.253.10 fc
<r3> 10.0.253.10 5f
<r3> 10.0.253.10 00
<r3> 10.0.253.10 02
<r3> 10.0.253.10 00
<r3> 10.0.253.10 00
<r3> 10.0.253.10 49
<r3> 10.0.253.10 0f
<r3> 10.0.253.10 af
<r3> 10.0.253.10 c6
<r3> 10.0.253.10 48
<r3> 10.0.253.10 c1
<r3> 10.0.253.10 e8
<r3> 10.0.253.10 20
<r3> 10.0.253.10 48
<r3> 10.0.253.10 8b
<r3> 10.0.253.10 15
<r3> 10.0.253.10 47
<r3> 10.0.253.10 e9
<r3> 10.0.253.10 05
<r3> 10.0.253.10 e2
<r3> 10.0.253.10 48
<r3> 10.0.253.10 8d
<r3> 10.0.253.10 04
<r3> 10.0.253.10 c2
<r3> 10.0.253.10 48
<r3> 10.0.253.10 8b
<r3> 10.0.253.10 00
<r3> 10.0.253.10 a8
<r3> 10.0.253.10 01
<r3> 10.0.253.10 0f
<r3> 10.0.253.10 85
<r3> 10.0.253.10 cc
<r3> 10.0.253.10 00
<r3> 10.0.253.10 00
<r3> 10.0.253.10 00
<r3> 10.0.253.10 b6
<r3> 10.0.253.10 50
<r3> 10.0.253.10 37
<r3> 10.0.253.10 48
<r3> 10.0.253.10 89
<r3> 10.0.253.10 c6
<r3> 10.0.253.10 48
<r3> 10.0.253.10 8b
<r3> 10.0.253.10 0d
<r3> 10.0.253.10 42
<r3> 10.0.253.10 e9
<r3> 10.0.253.10 05
<r3> 10.0.253.10 e2
<r3> 10.0.253.10 48
<r3> 10.0.253.10 6b
<r3> 10.0.253.10 d2
<r3> 10.0.253.10 38
<r3> 10.0.253.10 48
<r3> 10.0.253.10 83
<r3> 10.0.253.10 c2
<r3> 10.0.253.10
<r3> 10.0.253.10 [30436.211293] RIP
<r3> 10.0.253.10 [<ffffffffa0046340>] 
nf_conntrack_tuple_taken+0x7d/0x199 [nf_conntrack]
<r3> 10.0.253.10 [30436.211999]  RSP <ffff88042f083a78>
<r3> 10.0.253.10 [30436.212351] ---[ end trace 8edfb72dbd1328bd ]---
<r3> 10.0.253.10 [30436.224312] Kernel panic - not syncing: Fatal 
exception in interrupt
<r3> 10.0.253.10 [30436.224656] Kernel Offset: disabled
<r3> 10.0.253.10 [30436.253368] Rebooting in 5 seconds..

<r4> 10.0.253.10 [157391.289913] general protection fault: 0000 [#1]
<r4> 10.0.253.10 SMP
<r4> 10.0.253.10
<r4> 10.0.253.10 [157391.290403] Modules linked in:
<r4> 10.0.253.10 act_skbedit
<r4> 10.0.253.10 sch_fq
<r4> 10.0.253.10 cls_fw
<r4> 10.0.253.10 act_police
<r4> 10.0.253.10 cls_u32
<r4> 10.0.253.10 sch_ingress
<r4> 10.0.253.10 sch_sfq
<r4> 10.0.253.10 sch_htb
<r4> 10.0.253.10 netconsole
<r4> 10.0.253.10 configfs
<r4> 10.0.253.10 pppoe
<r4> 10.0.253.10 pppox
<r4> 10.0.253.10 ppp_generic
<r4> 10.0.253.10 slhc
<r4> 10.0.253.10 xt_nat
<r4> 10.0.253.10 ts_bm
<r4> 10.0.253.10 xt_string
<r4> 10.0.253.10 xt_connmark
<r4> 10.0.253.10 xt_TCPMSS
<r4> 10.0.253.10 xt_tcpudp
<r4> 10.0.253.10 xt_mark
<r4> 10.0.253.10 iptable_filter
<r4> 10.0.253.10 iptable_nat
<r4> 10.0.253.10 nf_conntrack_ipv4
<r4> 10.0.253.10 nf_defrag_ipv4
<r4> 10.0.253.10 nf_nat_ipv4
<r4> 10.0.253.10 nf_nat
<r4> 10.0.253.10 nf_conntrack
<r4> 10.0.253.10 iptable_mangle
<r4> 10.0.253.10 ip_tables
<r4> 10.0.253.10 x_tables
<r4> 10.0.253.10 8021q
<r4> 10.0.253.10 garp
<r4> 10.0.253.10 mrp
<r4> 10.0.253.10 stp
<r4> 10.0.253.10 llc
<r4> 10.0.253.10
<r4> 10.0.253.10 [157391.294503] CPU: 15 PID: 0 Comm: swapper/15 Not 
tainted 4.2.3-build-0087 #3
<r4> 10.0.253.10 [157391.294830] Hardware name: Intel Corporation 
S2600GZ/S2600GZ, BIOS SE5C600.86B.01.03.0002.062020121504 06/20/2012
<r4> 10.0.253.10 [157391.295347] task: ffff88042d299700 ti: 
ffff88042d2a4000 task.ti: ffff88042d2a4000
<r4> 10.0.253.10 [157391.295880] RIP: 0010:[<ffffffff8184549c>]
<r4> 10.0.253.10 [<ffffffff8184549c>] rt_cache_valid+0xb/0x29
<r4> 10.0.253.10 [157391.296570] RSP: 0018:ffff88042efe3948  EFLAGS: 
00010286
<r4> 10.0.253.10 [157391.296880] RAX: 0000000000000000 RBX: 
ffff88042efe3a58 RCX: ffff880414e3c200
<r4> 10.0.253.10 [157391.297437] RDX: ffff88042efe3901 RSI: 
000000005b2313ac RDI: ffa205040201b300
<r4> 10.0.253.10 [157391.298029] RBP: ffff88042efe3948 R08: 
ffff88042081e600 R09: ffff8804247375e0
<r4> 10.0.253.10 [157391.298562] R10: 0000000000000000 R11: 
000000000000000a R12: ffa205040201b300
<r4> 10.0.253.10 [157391.299159] R13: 0000000000000001 R14: 
0000000000000000 R15: ffff88042b362000
<r4> 10.0.253.10 [157391.299782] FS:  0000000000000000(0000) 
GS:ffff88042efe0000(0000) knlGS:0000000000000000
<r4> 10.0.253.10 [157391.300366] CS:  0010 DS: 0000 ES: 0000 CR0: 
0000000080050033
<r4> 10.0.253.10 [157391.300701] CR2: 00007fa0b0191b6c CR3: 
000000000200c000 CR4: 00000000000406e0
<r4> 10.0.253.10 [157391.301297] Stack:
<r4> 10.0.253.10 [157391.301643]  ffff88042efe39d8
<r4> 10.0.253.10 ffffffff81846b9e
<r4> 10.0.253.10 ffff88042efe3988
<r4> 10.0.253.10 0000000000000000
<r4> 10.0.253.10
<r4> 10.0.253.10 [157391.302631]  ffff88042081e600
<r4> 10.0.253.10 00000000200b96c0
<r4> 10.0.253.10 ffff8804200b9001
<r4> 10.0.253.10 ffff880414e3c200
<r4> 10.0.253.10
<r4> 10.0.253.10 [157391.303520]  00000000fd010020
<r4> 10.0.253.10 ffff88042081e600
<r4> 10.0.253.10 ffff88042c108880
<r4> 10.0.253.10 ffff8803e6085b08
<r4> 10.0.253.10
<r4> 10.0.253.10 [157391.304393] Call Trace:
<r4> 10.0.253.10 [157391.304709]  <IRQ>
<r4> 10.0.253.10
<r4> 10.0.253.10 [157391.304800]  [<ffffffff81846b9e>] 
__ip_route_output_key+0x47f/0x5d8
<r4> 10.0.253.10 [157391.305461]  [<ffffffff81846d8d>] 
ip_route_output_flow+0x18/0x42
<r4> 10.0.253.10 [157391.305819]  [<ffffffff81882cc6>] 
nf_ip_route+0x13/0x24
<r4> 10.0.253.10 [157391.306174]  [<ffffffffa00ab180>] 
tcpmss_tg4+0xf8/0x3c8 [xt_TCPMSS]
<r4> 10.0.253.10 [157391.306517]  [<ffffffffa00376c9>] ? 
ipt_do_table+0x572/0x58e [ip_tables]
<r4> 10.0.253.10 [157391.306880]  [<ffffffffa0037456>] 
ipt_do_table+0x2ff/0x58e [ip_tables]
<r4> 10.0.253.10 [157391.307241]  [<ffffffffa004cec4>] ? 
tcp_packet+0xc4a/0xd1e [nf_conntrack]
<r4> 10.0.253.10 [157391.307573]  [<ffffffffa009304a>] 
iptable_filter_hook+0x4a/0x4c [iptable_filter]
<r4> 10.0.253.10 [157391.308174]  [<ffffffff818442f0>] 
nf_iterate+0x4d/0x69
<r4> 10.0.253.10 [157391.308527]  [<ffffffff8184433a>] 
nf_hook_slow+0x2e/0x9f
<r4> 10.0.253.10 [157391.308867]  [<ffffffff8184a9b4>] 
ip_forward+0x367/0x379
<r4> 10.0.253.10 [157391.309193]  [<ffffffff8184a5ee>] ? 
ip_frag_mem+0x3d/0x3d
<r4> 10.0.253.10 [157391.309551]  [<ffffffff81849178>] 
ip_rcv_finish+0x252/0x28e
<r4> 10.0.253.10 [157391.309884]  [<ffffffff818495c7>] 
ip_rcv+0x294/0x312
<r4> 10.0.253.10 [157391.310271]  [<ffffffff81848f26>] ? 
ip_local_deliver_finish+0x19c/0x19c
<r4> 10.0.253.10 [157391.310646]  [<ffffffff8181c813>] 
__netif_receive_skb_core+0x645/0x7b4
<r4> 10.0.253.10 [157391.311006]  [<ffffffffa00e38f8>] ? 
htb_dequeue+0x410/0x70f [sch_htb]
<r4> 10.0.253.10 [157391.311373]  [<ffffffff8181d1b8>] 
__netif_receive_skb+0x13/0x55
<r4> 10.0.253.10 [157391.311724]  [<ffffffff8181de31>] 
process_backlog+0x91/0x111
<r4> 10.0.253.10 [157391.312079]  [<ffffffff8181dc44>] 
net_rx_action+0xf9/0x255
<r4> 10.0.253.10 [157391.312411]  [<ffffffff810bf54c>] 
__do_softirq+0xb9/0x1a8
<r4> 10.0.253.10 [157391.312759]  [<ffffffff810bf787>] 
irq_exit+0x37/0x7c
<r4> 10.0.253.10 [157391.313111]  [<ffffffff81028010>] 
smp_call_function_single_interrupt+0x2e/0x30
<r4> 10.0.253.10 [157391.313700]  [<ffffffff818a6915>] 
call_function_single_interrupt+0x65/0x70
<r4> 10.0.253.10 [157391.314038]  <EOI>
<r4> 10.0.253.10
<r4> 10.0.253.10 [157391.314139]  [<ffffffff8100ae89>] ? 
mwait_idle+0x68/0x7e
<r4> 10.0.253.10 [157391.314869]  [<ffffffff810d263e>] ? 
atomic_notifier_call_chain+0x13/0x15
<r4> 10.0.253.10 [157391.315205]  [<ffffffff8100b28b>] 
arch_cpu_idle+0xa/0xc
<r4> 10.0.253.10 [157391.315550]  [<ffffffff810e337b>] 
default_idle_call+0x27/0x29
<r4> 10.0.253.10 [157391.315911]  [<ffffffff810e349e>] 
cpu_startup_entry+0x121/0x1da
<r4> 10.0.253.10 [157391.316290]  [<ffffffff8102868e>] 
start_secondary+0xfc/0x11a
<r4> 10.0.253.10 [157391.316654] Code:
<r4> 10.0.253.10 7f
<r4> 10.0.253.10 66
<r4> 10.0.253.10 ff
<r4> 10.0.253.10 48
<r4> 10.0.253.10 89
<r4> 10.0.253.10 e5
<r4> 10.0.253.10 75
<r4> 10.0.253.10 14
<r4> 10.0.253.10 31
<r4> 10.0.253.10 c0
<r4> 10.0.253.10 8b
<r4> 10.0.253.10 15
<r4> 10.0.253.10 9f
<r4> 10.0.253.10 f5
<r4> 10.0.253.10 85
<r4> 10.0.253.10 00
<r4> 10.0.253.10 39
<r4> 10.0.253.10 97
<r4> 10.0.253.10 98
<r4> 10.0.253.10 00
<r4> 10.0.253.10 00
<r4> 10.0.253.10 00
<r4> 10.0.253.10 48
<r4> 10.0.253.10 0f
<r4> 10.0.253.10 44
<r4> 10.0.253.10 c7
<r4> 10.0.253.10 eb
<r4> 10.0.253.10 02
<r4> 10.0.253.10 31
<r4> 10.0.253.10 c0
<r4> 10.0.253.10 5d
<r4> 10.0.253.10 c3
<r4> 10.0.253.10 55
<r4> 10.0.253.10 31
<r4> 10.0.253.10 c0
<r4> 10.0.253.10 48
<r4> 10.0.253.10 85
<r4> 10.0.253.10 ff
<r4> 10.0.253.10 48
<r4> 10.0.253.10 89
<r4> 10.0.253.10 e5
<r4> 10.0.253.10 74
<r4> 10.0.253.10 19
<r4> 10.0.253.10
<r4> 10.0.253.10 83
<r4> 10.0.253.10 7f
<r4> 10.0.253.10 66
<r4> 10.0.253.10 ff
<r4> 10.0.253.10 75
<r4> 10.0.253.10 12
<r4> 10.0.253.10 8b
<r4> 10.0.253.10 05
<r4> 10.0.253.10 77
<r4> 10.0.253.10 f5
<r4> 10.0.253.10 85
<r4> 10.0.253.10 00
<r4> 10.0.253.10 39
<r4> 10.0.253.10 87
<r4> 10.0.253.10 98
<r4> 10.0.253.10 00
<r4> 10.0.253.10 00
<r4> 10.0.253.10 00
<r4> 10.0.253.10 0f
<r4> 10.0.253.10 94
<r4> 10.0.253.10
<r4> 10.0.253.10 [157391.323078] RIP
<r4> 10.0.253.10 [<ffffffff8184549c>] rt_cache_valid+0xb/0x29
<r4> 10.0.253.10 [157391.323492]  RSP <ffff88042efe3948>
<r4> 10.0.253.10 [157391.323824] ---[ end trace 4d92d1ab89ffe3b0 ]---
<r4> 10.0.253.10 [157391.337810] Kernel panic - not syncing: Fatal 
exception in interrupt
<r4> 10.0.253.10 [157391.338166] Kernel Offset: disabled
<r4> 10.0.253.10 [157391.377769] Rebooting in 5 seconds..
