From: "Yinghai Lu" <yhlu.kernel@gmail.com>
Subject: Re: skbuff bug?
Date: Thu, 21 Aug 2008 16:46:49 -0700
Message-ID: <86802c440808211646y758cfdd7n505777b2b8b58c9a@mail.gmail.com>
References: <86802c440808202056j6cfe5ca0v6284140ae4b9b8cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>,
	"Jeff Garzik" <jeff@garzik.org>, "Ingo Molnar" <mingo@elte.hu>,
	"Bruce Allan" <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.237]:37945 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbYHUXqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 19:46:49 -0400
Received: by rv-out-0506.google.com with SMTP id k40so182992rvb.1
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 16:46:49 -0700 (PDT)
In-Reply-To: <86802c440808202056j6cfe5ca0v6284140ae4b9b8cd@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

it seems caused by

commit f8d59f7826aa73c5e7682fbed6db38020635d466
Author: Bruce Allan <bruce.w.allan@intel.com>
Date:   Fri Aug 8 18:36:11 2008 -0700

    e1000e: test for unusable MSI support

    Some systems do not like 82571/2 use of 16-bit MSI messages and some
    other systems claim to support MSI, but neither really works.  Setup a
    test MSI handler to detect whether or not MSI is working properly, and
    if not, fallback to legacy INTx interrupts.

    Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
    Signed-off-by: Jeff Garzik <jgarzik@redhat.com>


because sometime got

calling  ip_auto_config+0x0/0xec1
BUG: unable to handle kernel NULL pointer dereference at 00000000000000a8
IP: [<ffffffff80566e31>] e1000_clean+0xb6/0x4cc
PGD 0
Oops: 0000 [1] SMP
Dumping ftrace buffer:
   (ftrace buffer empty)
CPU 3
Modules linked in:
Pid: 0, comm: swapper Not tainted 2.6.27-rc4-tip-00862-gcc150c8-dirty #140
RIP: 0010:[<ffffffff80566e31>]  [<ffffffff80566e31>] e1000_clean+0xb6/0x4cc
RSP: 0018:ffff880826527e10  EFLAGS: 00010246
RAX: ffff880823964000 RBX: 0000000000000000 RCX: 0000000000000000
RDX: ffff880823964000 RSI: 0000000000000000 RDI: ffffc200147b1000
RBP: ffff880826527ea0 R08: 0000000000000032 R09: 0000000000000000
R10: ffff880826527f78 R11: ffff88042655fe98 R12: 0000000000000000
R13: ffff880824110780 R14: ffff880423da0640 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff8804264ba300(0000) knlGS:0000000000000000
CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
CR2: 00000000000000a8 CR3: 0000000000201000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process swapper (pid: 0, threadinfo ffff88042655e000, task ffff880426561680)
Stack:  ffffffff802750f5 ffff880826527e48 ffffffff8027613e ffffffff8026a1fc
 0000001470188100 00000040280809a0 ffff880824110908 0000000000000000
 0000000001000286 ffff880824110000 ffff880823964000 ffff880824110780
Call Trace:
 <IRQ>  [<ffffffff802750f5>] ? clockevents_program_event+0x81/0x8a
 [<ffffffff8027613e>] ? tick_program_event+0x3f/0x5f
 [<ffffffff8026a1fc>] ? __queue_work+0x7c/0x85
 [<ffffffff8089cb3c>] net_rx_action+0x7f/0x159
 [<ffffffff8025ec38>] __do_softirq+0x72/0xe2
 [<ffffffff80565ac0>] ? e1000_intr_msi+0x100/0x10a
 [<ffffffff8022835c>] call_softirq+0x1c/0x28
 [<ffffffff802295b0>] do_softirq+0x39/0x77
 [<ffffffff8025e94c>] irq_exit+0x44/0x87
 [<ffffffff80229907>] do_IRQ+0x146/0x168
 [<ffffffff802275c1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8022d69c>] ? default_idle+0x30/0x45
 [<ffffffff8022d832>] ? c1e_idle+0xd5/0xdc
 [<ffffffff80966fea>] ? atomic_notifier_call_chain+0x13/0x15
 [<ffffffff80226271>] ? cpu_idle+0xd9/0x121
 [<ffffffff8095e2a7>] ? start_secondary+0x16f/0x174
Code: c6 45 b3 00 e9 b0 00 00 00 49 8b 16 41 89 dc 49 6b fc 28 48 89
55 c0 49 03 7e 20 3b 5d b4 0f 94 45 b3 75 39 48 8b 4f 08 8b
<6>0000:87:00.0: eth4: MSI interrupt test failed!
0000:87:00.0: eth4: MSI interrupt test failed, using legacy interrupt.
75 ac <8b> 91 a8 00 00 00 48 8b 81 b0 00 00 00 0f b7 44 10 08 ba 01 00
RIP  [<ffffffff80566e31>] e1000_clean+0xb6/0x4cc
 RSP <ffff880826527e10>
CR2: 00000000000000a8
do_IRQ: 3.131 No irq handler for vector
Kernel panic - not syncing: Fatal exception in interrupt
Pid: 0, comm: swapper Tainted: G      D
2.6.27-rc4-tip-00862-gcc150c8-dirty #140
Call Trace:
 <IRQ>  [<ffffffff80961e69>] panic+0xa5/0x15c
 [<ffffffff8025a1fc>] ? printk_ratelimit+0x15/0x17
 [<ffffffff802275c1>] ? ret_from_intr+0x0/0xa
 [<ffffffff80964e26>] ? oops_end+0x42/0xa4
 [<ffffffff80964e6b>] oops_end+0x87/0xa4
 [<ffffffff80966e79>] do_page_fault+0x7cb/0x8bf
 [<ffffffff804c0a26>] ? __bitmap_weight+0x3e/0x89
 [<ffffffff804c0a26>] ? __bitmap_weight+0x3e/0x89
 [<ffffffff8024c4e0>] ? __enqueue_entity+0x8a/0x8c
 [<ffffffff8024dcf7>] ? enqueue_entity+0x195/0x19d
 [<ffffffff8024dd45>] ? enqueue_task_fair+0x46/0x4b
 [<ffffffff8024a2d3>] ? enqueue_task+0x50/0x5b
 [<ffffffff80964829>] error_exit+0x0/0x51
 [<ffffffff80566e31>] ? e1000_clean+0xb6/0x4cc
 [<ffffffff802750f5>] ? clockevents_program_event+0x81/0x8a
 [<ffffffff8027613e>] ? tick_program_event+0x3f/0x5f
 [<ffffffff8026a1fc>] ? __queue_work+0x7c/0x85
 [<ffffffff8089cb3c>] net_rx_action+0x7f/0x159
 [<ffffffff8025ec38>] __do_softirq+0x72/0xe2
 [<ffffffff80565ac0>] ? e1000_intr_msi+0x100/0x10a
 [<ffffffff8022835c>] call_softirq+0x1c/0x28
 [<ffffffff802295b0>] do_softirq+0x39/0x77
 [<ffffffff8025e94c>] irq_exit+0x44/0x87
 [<ffffffff80229907>] do_IRQ+0x146/0x168
 [<ffffffff802275c1>] ret_from_intr+0x0/0xa
 <EOI>  [<ffffffff8022d69c>] ? default_idle+0x30/0x45
 [<ffffffff8022d832>] ? c1e_idle+0xd5/0xdc
 [<ffffffff80966fea>] ? atomic_notifier_call_chain+0x13/0x15
 [<ffffffff80226271>] ? cpu_idle+0xd9/0x121
 [<ffffffff8095e2a7>] ? start_secondary+0x16f/0x174


the system got several intel pcie quad ports cards installed

YH
