From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: skbuff bug?
Date: Thu, 21 Aug 2008 18:23:15 -0700
Message-ID: <86802c440808211823q1ca2f8f7k96cc9c824ab675a2@mail.gmail.com>
References: <86802c440808202056j6cfe5ca0v6284140ae4b9b8cd@mail.gmail.com>
	 <86802c440808211646y758cfdd7n505777b2b8b58c9a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jeff@garzik.org>, "Ingo Molnar" <mingo@elte.hu>,
	"Bruce Allan" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.232]:46409 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274AbYHVBXQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 21:23:16 -0400
Received: by rv-out-0506.google.com with SMTP id k40so211831rvb.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 18:23:15 -0700 (PDT)
In-Reply-To: <86802c440808211646y758cfdd7n505777b2b8b58c9a@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

another one

skb_over_panic: text:ffffffff80568ad9 len:10742 put:10742
head:ffff8808236ac800 data:ffff8808236ac812 tail:0x2a08 end:0x680
dev:eth2
------------[ cut here ]------------
kernel BUG at net/core/skbuff.c:128!
invalid opcode: 0000 [1] SMP
Dumping ftrace buffer:
   (ftrace buffer empty)
CPU 3
Modules linked in:
Pid: 0, comm: swapper Not tainted 2.6.27-rc4-tip-00862-gcc150c8-dirty #144
RIP: 0010:[<ffffffff808985bb>]  [<ffffffff808985bb>] skb_put+0x82/0x8e
RSP: 0018:ffff880426567d30  EFLAGS: 00010286
RAX: 0000000000000088 RBX: ffff880823c80780 RCX: 0000000000006280
RDX: ffff8800a70ed000 RSI: 0000000000000046 RDI: ffffffff80fe7804
RBP: ffff880426567d50 R08: ffff880426567b80 R09: 0000000000000000
R10: ffffffff81067d10 R11: 0000000000000010 R12: ffffc200147ad9d8
R13: 00000000000029f6 R14: ffff88082367e500 R15: ffff880423a3c3f0
FS:  00007f4d6c6c36f0(0000) GS:ffff8804264be300(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00007f4d6c9694e8 CR3: 000000041fc45000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff880826526000, task ffff880426559680)
Stack:  0000000000002a08 0000000000000680 ffff880823c80000 0000000000000501
 ffff880426567e00 ffffffff80568ad9 00000000ffff9c73 0000040000000001
 000000402301c288 ffff880426567e74 ffff880400000013 ffff880823c80000
Call Trace:
 <IRQ>  [<ffffffff80568ad9>] e1000_clean_rx_irq+0x1e9/0x2c4
 [<ffffffff80567091>] e1000_clean+0x316/0x4cc
 [<ffffffff802750f5>] ? clockevents_program_event+0x81/0x8a
 [<ffffffff8027613e>] ? tick_program_event+0x3f/0x5f
 [<ffffffff8089cb3c>] net_rx_action+0x7f/0x159
 [<ffffffff8025ec38>] __do_softirq+0x72/0xe2
 [<ffffffff80565ac0>] ? e1000_intr_msi+0x100/0x10a
 [<ffffffff8022835c>] call_softirq+0x1c/0x28
 [<ffffffff802295b0>] do_softirq+0x39/0x77
 [<ffffffff8025e94c>] irq_exit+0x44/0x87
 [<ffffffff80229907>] do_IRQ+0x146/0x168
 [<ffffffff802275c1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8024c75c>] ? pick_next_task_fair+0x9d/0xac
 [<ffffffff8022d69c>] ? default_idle+0x30/0x45
 [<ffffffff8022d832>] ? c1e_idle+0xd5/0xdc
 [<ffffffff80966fea>] ? atomic_notifier_call_chain+0x13/0x15
 [<ffffffff80226271>] ? cpu_idle+0xd9/0x121
 [<ffffffff8095e2a7>] ? start_secondary+0x16f/0x174
Code: 8b 57 68 48 89 44 24 10 8b 87 a8 00 00 00 48 89 44 24 08 8b bf
a4 00 00 00 31 c0 48 89 3c 24 48 c7 c7 4c 82 d2 80 e8 65 99 0c 00 <0f>
0b eb fe 89 d0 c9 49 8d 04 00 c3 55 48 89 e5 41 56 41 55 41
RIP  [<ffffffff808985bb>] skb_put+0x82/0x8e
 RSP <ffff880426567d30>
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D
2.6.27-rc4-tip-00862-gcc150c8-dirty #144
Call Trace:
 <IRQ>  [<ffffffff80961e69>] panic+0xa5/0x15c
 [<ffffffff80227da6>] ? apic_timer_interrupt+0x66/0x70
 [<ffffffff80964e26>] ? oops_end+0x42/0xa4
 [<ffffffff80964e6b>] oops_end+0x87/0xa4
 [<ffffffff80228c60>] die+0x62/0x6b
 [<ffffffff8096547c>] do_trap+0x110/0x11f
 [<ffffffff802292cd>] do_invalid_op+0x98/0xa1
 [<ffffffff808985bb>] ? skb_put+0x82/0x8e
 [<ffffffff808ce840>] ? tcp_v4_rcv+0x3ad/0x594
 [<ffffffff80961f8c>] ? printk+0x6c/0x70
 [<ffffffff80964829>] error_exit+0x0/0x51
 [<ffffffff808985bb>] ? skb_put+0x82/0x8e
 [<ffffffff80568ad9>] e1000_clean_rx_irq+0x1e9/0x2c4
 [<ffffffff80567091>] e1000_clean+0x316/0x4cc
 [<ffffffff802750f5>] ? clockevents_program_event+0x81/0x8a
 [<ffffffff8027613e>] ? tick_program_event+0x3f/0x5f
 [<ffffffff8089cb3c>] net_rx_action+0x7f/0x159
 [<ffffffff8025ec38>] __do_softirq+0x72/0xe2
 [<ffffffff80565ac0>] ? e1000_intr_msi+0x100/0x10a
 [<ffffffff8022835c>] call_softirq+0x1c/0x28
 [<ffffffff802295b0>] do_softirq+0x39/0x77
 [<ffffffff8025e94c>] irq_exit+0x44/0x87
 [<ffffffff80229907>] do_IRQ+0x146/0x168
 [<ffffffff802275c1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8024c75c>] ? pick_next_task_fair+0x9d/0xac
 [<ffffffff8022d69c>] ? default_idle+0x30/0x45
 [<ffffffff8022d832>] ? c1e_idle+0xd5/0xdc
 [<ffffffff80966fea>] ? atomic_notifier_call_chain+0x13/0x15
 [<ffffffff80226271>] ? cpu_idle+0xd9/0x121
 [<ffffffff8095e2a7>] ? start_secondary+0x16f/0x174
