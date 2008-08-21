From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: skbuff bug?
Date: Wed, 20 Aug 2008 20:56:38 -0700
Message-ID: <86802c440808202056j6cfe5ca0v6284140ae4b9b8cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jeff@garzik.org>, "Ingo Molnar" <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:16265 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754529AbYHUD4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 23:56:38 -0400
Received: by rv-out-0506.google.com with SMTP id k40so766430rvb.1
        for <netdev@vger.kernel.org>; Wed, 20 Aug 2008 20:56:38 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb_over_panic: text:ffffffff8056cec7 len:27760 put:27760
head:ffff880821c9b800 data:ffff880821c9b812 tail:0x6c82 end:0x680
dev:eth10
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:128!
invalid opcode: 0000 [1] SMP
Dumping ftrace buffer:
   (ftrace buffer empty)
CPU 0
Modules linked in:
Pid: 0, comm: swapper Not tainted 2.6.27-rc3-tip-00674-g64e34ec-dirty #126
RIP: 0010:[<ffffffff8089c163>]  [<ffffffff8089c163>] skb_put+0x82/0x8e
RSP: 0018:ffffffff80fa2d30  EFLAGS: 00010286
RAX: 0000000000000089 RBX: ffff880822e6c780 RCX: 0000000000000641
RDX: 0000000000000641 RSI: 0000000000000046 RDI: ffffffff80fec804
RBP: ffffffff80fa2d50 R08: ffffffff80fa2b80 R09: 0000000000000000
R10: ffffffff8106cd10 R11: 0000000000000010 R12: ffffc2002d0f1028
R13: 0000000000006c70 R14: ffff880821c5fb00 R15: ffff8838237f4010
FS:  0000000000000000(0000) GS:ffffffff80ecae00(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007fff017b2fe8 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffffffff80ed0000, task ffffffff80db23b0)
Stack:  0000000000006c82 0000000000000680 ffff880822e6c000 0000000000000001
 ffffffff80fa2e00 ffffffff8056cec7 0000000000000040 ffff880822e70780
 00000040231ee340 ffffffff80fa2e74 0000003e00000053 ffff880822e6c000
Call Trace:
 <IRQ>  [<ffffffff8056cec7>] e1000_clean_rx_irq+0x1e9/0x2c4
 [<ffffffff8056b47f>] e1000_clean+0x316/0x4cc
 [<ffffffff8028e9ec>] ? handle_edge_irq+0xfb/0x11f
 [<ffffffff808a05a4>] net_rx_action+0x7f/0x159
 [<ffffffff8025fa48>] __do_softirq+0x72/0xe2
 [<ffffffff80569d8f>] ? e1000_intr_msi+0x100/0x10a
 [<ffffffff8022835c>] call_softirq+0x1c/0x28
 [<ffffffff802295b0>] do_softirq+0x39/0x77
 [<ffffffff8025f75c>] irq_exit+0x44/0x87
 [<ffffffff802298fa>] do_IRQ+0x146/0x168
 [<ffffffff802275c1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8022d64c>] ? default_idle+0x30/0x45
 [<ffffffff8022d7e2>] ? c1e_idle+0xd5/0xdc
 [<ffffffff8096a87a>] ? atomic_notifier_call_chain+0x13/0x15
 [<ffffffff80226271>] ? cpu_idle+0xd9/0x121
 [<ffffffff8092ba72>] ? rest_init+0x66/0x68
 [<ffffffff80ee1df3>] ? start_kernel+0x3ab/0x3b6
 [<ffffffff80ee1296>] ? x86_64_start_reservations+0xa5/0xa9
 [<ffffffff80ee13af>] ? x86_64_start_kernel+0xf2/0xf9
Code: 8b 57 68 48 89 44 24 10 8b 87 a8 00 00 00 48 89 44 24 08 8b bf
a4 00 00 00 31 c0 48 89 3c 24 48 c7 c7 6c ca d2 80 e8 4e 96 0c 00 <0f>
0b eb fe 89 d0 c9 49 8d 04 00 c3 55 48 89 e5 41 56 41 55 41
RIP  [<ffffffff8089c163>] skb_put+0x82/0x8e
 RSP <ffffffff80fa2d30>
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D
2.6.27-rc3-tip-00674-g64e34ec-dirty #126
Call Trace:
 <IRQ>  [<ffffffff809656fa>] panic+0xa5/0x15c
 [<ffffffff80227da6>] ? apic_timer_interrupt+0x66/0x70
 [<ffffffff809686b6>] ? oops_end+0x42/0xa4
 [<ffffffff809686fb>] oops_end+0x87/0xa4
 [<ffffffff80228c60>] die+0x62/0x6b
 [<ffffffff80968d0c>] do_trap+0x110/0x11f
 [<ffffffff802292cd>] do_invalid_op+0x98/0xa1
 [<ffffffff8089c163>] ? skb_put+0x82/0x8e
 [<ffffffff802c40ff>] ? add_partial+0x1f/0x6c
 [<ffffffff8096581d>] ? printk+0x6c/0x6f
 [<ffffffff809680b9>] error_exit+0x0/0x51
 [<ffffffff8089c163>] ? skb_put+0x82/0x8e
 [<ffffffff8056cec7>] e1000_clean_rx_irq+0x1e9/0x2c4
 [<ffffffff8056b47f>] e1000_clean+0x316/0x4cc
 [<ffffffff8028e9ec>] ? handle_edge_irq+0xfb/0x11f
 [<ffffffff808a05a4>] net_rx_action+0x7f/0x159
 [<ffffffff8025fa48>] __do_softirq+0x72/0xe2
 [<ffffffff80569d8f>] ? e1000_intr_msi+0x100/0x10a
 [<ffffffff8022835c>] call_softirq+0x1c/0x28
 [<ffffffff802295b0>] do_softirq+0x39/0x77
 [<ffffffff8025f75c>] irq_exit+0x44/0x87
 [<ffffffff802298fa>] do_IRQ+0x146/0x168
 [<ffffffff802275c1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8022d64c>] ? default_idle+0x30/0x45
 [<ffffffff8022d7e2>] ? c1e_idle+0xd5/0xdc
 [<ffffffff8096a87a>] ? atomic_notifier_call_chain+0x13/0x15
 [<ffffffff80226271>] ? cpu_idle+0xd9/0x121
 [<ffffffff8092ba72>] ? rest_init+0x66/0x68
 [<ffffffff80ee1df3>] ? start_kernel+0x3ab/0x3b6
 [<ffffffff80ee1296>] ? x86_64_start_reservations+0xa5/0xa9
 [<ffffffff80ee13af>] ? x86_64_start_kernel+0xf2/0xf9
