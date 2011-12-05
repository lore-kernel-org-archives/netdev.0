From: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Subject: 3.0.8 not syncing: Fatal exception in interrupt
Date: Mon, 05 Dec 2011 07:21:17 +0100
Message-ID: <4EDC62DD.6050405@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server655-han.de-nserver.de ([85.158.177.45]:45637 "EHLO
	server655-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752074Ab1LEGVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 01:21:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear list,

i encountered the following bug today while running v3.0.8

Better readable here:
http://pastebin.com/raw.php?i=2s75P0wF

2011-12-05 02:57:41     CS: 0010 DS: 0000 ES: 0000 CR0: 000000008005003b
2011-12-05 02:57:41     CR2: 000000000000002c CR3: 0000000119bb2000 CR4:
00000000000006e0
2011-12-05 02:57:41     DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
2011-12-05 02:57:41     DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
2011-12-05 02:57:41     Process kworker/0:1 (pid: 0, threadinfo
ffff88011af2c000, task ffff88011af09820)Stack:
2011-12-05 02:57:41     ffff88002589f6e0 ffff880052664d00
ffff880061911c00 ffff88010572c000
2011-12-05 02:57:41     ffff88011fd03d30 ffffffff814f56e2
ffff880061911c00 ffff880061911c00
2011-12-05 02:57:41     ffff88011fd03d80 ffffffff8155e4c6
ffff88011fd03e20 ffffffff81497230
2011-12-05 02:57:41     Call Trace:<IRQ>
2011-12-05 02:57:41     [<ffffffff814f56e2>] __sk_dst_check+0x42/0x70
2011-12-05 02:57:41     [<ffffffff8155e4c6>]
inet_sk_rebuild_header+0x26/0x330
2011-12-05 02:57:41     [<ffffffff81497230>] ? tg3_poll_work+0x1e0/0xe80
2011-12-05 02:57:41     [<ffffffff81548afb>] tcp_retransmit_skb+0xab/0x640
2011-12-05 02:57:41     [<ffffffff81012ca4>] ? x86_pmu_enable+0x1f4/0x270
2011-12-05 02:57:41     [<ffffffff8154b91e>]
tcp_retransmit_timer+0x26e/0x6e0
2011-12-05 02:57:41     [<ffffffff8154bf28>] tcp_write_timer+0x198/0x210
2011-12-05 02:57:41     [<ffffffff81055e3c>] run_timer_softirq+0x1cc/0x320
2011-12-05 02:57:41     [<ffffffff8154bd90>] ?
tcp_retransmit_timer+0x6e0/0x6e0
2011-12-05 02:57:41     [<ffffffff8101dfb8>] ? lapic_next_event+0x18/0x20
2011-12-05 02:57:41     [<ffffffff8104d1d0>] __do_softirq+0xd0/0x1c0
2011-12-05 02:57:41     [<ffffffff815d1d0c>] call_softirq+0x1c/0x30
2011-12-05 02:57:41     [<ffffffff81004a05>] do_softirq+0x55/0x90
2011-12-05 02:57:41     [<ffffffff8104cfcd>] irq_exit+0x7d/0xa0
2011-12-05 02:57:41     [<ffffffff8101eca9>]
smp_apic_timer_interrupt+0x69/0xa0
2011-12-05 02:57:41     [<ffffffff815d14d3>]
apic_timer_interrupt+0x13/0x20<EOI>
2011-12-05 02:57:41     [<ffffffff815d14ce>] ? apic_timer_interrupt+0xe/0x20
2011-12-05 02:57:41     [<ffffffff8100b7b7>] ? mwait_idle+0x117/0x120
2011-12-05 02:57:41     [<ffffffff8106cfd5>] ?
atomic_notifier_call_chain+0x15/0x20
2011-12-05 02:57:41     [<ffffffff8100208d>] cpu_idle+0xad/0xf0
2011-12-05 02:57:41     [<ffffffff815c79aa>] start_secondary+0x201/0x297
2011-12-05 02:57:41     Code: 51 a2 8e 00 89 83 d4 00 00 00 eb 9b 48 85
db 74 16 48 8b 53 40 31 ff 48 85 d2 74 0f 48 8b 05 f2 04 5a 00 48 89 42
18 48 8b 7b 40 <f0> ff 4f 2c 0f 94 c0 84 c0 0f 85 ac 00 00 00 48 c7 43
40 00 00
2011-12-05 02:57:41     RIP [<ffffffff81528796>] ipv4_dst_check+0xb6/0x190
2011-12-05 02:57:41     RSP <ffff88011fd03cf0>
2011-12-05 02:57:41     CR2: 000000000000002c
2011-12-05 02:57:41     ---[ end trace bd99ce386f3021bd ]---
2011-12-05 02:57:41     Kernel panic - not syncing: Fatal exception in
interrupt
2011-12-05 02:57:41     Pid: 0, comm: kworker/0:1 Tainted: G D 2.6.40.8p4 #1
2011-12-05 02:57:41     Call Trace:
2011-12-05 02:57:41     <IRQ> [<ffffffff815cd21c>] panic+0xba/0x1e5
2011-12-05 02:57:41     [<ffffffff815d14d3>] ?
apic_timer_interrupt+0x13/0x20
2011-12-05 02:57:41     [<ffffffff8104717a>] ? kmsg_dump+0x4a/0x100
2011-12-05 02:57:41     [<ffffffff81005ec4>] oops_end+0xd4/0xe0
2011-12-05 02:57:41     [<ffffffff81029501>] no_context+0xf1/0x270
2011-12-05 02:57:41     [<ffffffff810297d5>]
__bad_area_nosemaphore+0x155/0x200
2011-12-05 02:57:41     [<ffffffff810fa37b>] ? kmem_cache_free+0x1b/0xf0
2011-12-05 02:57:41     [<ffffffff814f8f72>] ? __kfree_skb+0x42/0xa0
2011-12-05 02:57:41     [<ffffffff81545b84>] ?
tcp_rcv_established+0x364/0x630
2011-12-05 02:57:41     [<ffffffff8154f364>] ? tcp_v4_do_rcv+0x154/0x2d0
2011-12-05 02:57:41     [<ffffffff8102988e>] bad_area_nosemaphore+0xe/0x10
2011-12-05 02:57:41     [<ffffffff81029e1e>] do_page_fault+0x2ee/0x420
2011-12-05 02:57:41     [<ffffffff8154fbdb>] ? tcp_v4_rcv+0x6fb/0x880
2011-12-05 02:57:41     [<ffffffff8152d087>] ?
ip_local_deliver_finish+0x127/0x250
2011-12-05 02:57:41     [<ffffffff8152d23d>] ? ip_local_deliver+0x8d/0xa0
2011-12-05 02:57:41     [<ffffffff8152c942>] ? ip_rcv_finish+0x172/0x340
2011-12-05 02:57:41     [<ffffffff815d079f>] page_fault+0x1f/0x30
2011-12-05 02:57:41     [<ffffffff81528796>] ? ipv4_dst_check+0xb6/0x190
2011-12-05 02:57:41     [<ffffffff814f56e2>] __sk_dst_check+0x42/0x70
2011-12-05 02:57:41     [<ffffffff8155e4c6>]
inet_sk_rebuild_header+0x26/0x330
2011-12-05 02:57:41     [<ffffffff81497230>] ? tg3_poll_work+0x1e0/0xe80
2011-12-05 02:57:41     [<ffffffff81548afb>] tcp_retransmit_skb+0xab/0x640
2011-12-05 02:57:41     [<ffffffff81012ca4>] ? x86_pmu_enable+0x1f4/0x270
2011-12-05 02:57:41     [<ffffffff8154b91e>]
tcp_retransmit_timer+0x26e/0x6e0
2011-12-05 02:57:41     [<ffffffff8154bf28>] tcp_write_timer+0x198/0x210
2011-12-05 02:57:41     [<ffffffff81055e3c>] run_timer_softirq+0x1cc/0x320
2011-12-05 02:57:41     [<ffffffff8154bd90>] ?
tcp_retransmit_timer+0x6e0/0x6e0
2011-12-05 02:57:41     [<ffffffff8101dfb8>] ? lapic_next_event+0x18/0x20
2011-12-05 02:57:41     [<ffffffff8104d1d0>] __do_softirq+0xd0/0x1c0
2011-12-05 02:57:41     [<ffffffff815d1d0c>] call_softirq+0x1c/0x30
2011-12-05 02:57:41     [<ffffffff81004a05>] do_softirq+0x55/0x90
2011-12-05 02:57:41     [<ffffffff8104cfcd>] irq_exit+0x7d/0xa0
2011-12-05 02:57:41     [<ffffffff8101eca9>]
smp_apic_timer_interrupt+0x69/0xa0
2011-12-05 02:57:41     [<ffffffff815d14d3>] apic_timer_interrupt+0x13/0x20
2011-12-05 02:57:41     <EOI> [<ffffffff815d14ce>] ?
apic_timer_interrupt+0xe/0x20
2011-12-05 02:57:41     [<ffffffff8100b7b7>] ? mwait_idle+0x117/0x120
2011-12-05 02:57:41     [<ffffffff8106cfd5>] ?
atomic_notifier_call_chain+0x15/0x20
2011-12-05 02:57:41     [<ffffffff8100208d>] cpu_idle+0xad/0xf0
2011-12-05 02:57:41     [<ffffffff815c79aa>] start_secondary+0x201/0x297
2011-12-05 02:57:41     BUG: unable to handle kernel NULL pointer
dereference at 000000000000002c
2011-12-05 02:57:41     IP: [<ffffffff81528796>] ipv4_dst_check+0xb6/0x190
2011-12-05 02:57:41     PGD 119889067 PUD 1167d2067 PMD 0
2011-12-05 02:57:41     Oops: 0002 [#2] SMP
2011-12-05 02:57:41     CPU 2
2011-12-05 02:57:41     Modules linked in: ipt_REJECT xt_tcpudp
iptable_filter ip_tables x_tables coretemp k8temp ipv6 dm_snapshot dm_mod
2011-12-05 02:57:41     Pid: 0, comm: kworker/0:1 Tainted: G D
2.6.40.8p4 #1 FUJITSU SIEMENS D2581-A5 /D2581-A5
2011-12-05 02:57:41     RIP: 0010:[<ffffffff81528796>]
[<ffffffff81528796>] ipv4_dst_check+0xb6/0x190
2011-12-05 02:57:41     RSP: 0018:ffff88011fd03cf0 EFLAGS: 00010282
2011-12-05 02:57:41     RAX: 00000001a916c098 RBX: ffff880052664d00 RCX:
0000000000000000
2011-12-05 02:57:41     RDX: ffff88002a179a40 RSI: ffff880027c3ff98 RDI:
0000000000000000
2011-12-05 02:57:41     RBP: ffff88011fd03d10 R08: 0000000000000000 R09:
0000000000000000
2011-12-05 02:57:41     R10: 0000000000000000 R11: ffffffff81604c10 R12:
ffff880027c3ff00
2011-12-05 02:57:41     R13: 0000000001b79e55 R14: ffff88010572c028 R15:
0000000000000100
2011-12-05 02:57:41     FS: 0000000000000000(0000)
GS:ffff88011fd00000(0000) knlGS:0000000000000000


Stefan
