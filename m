From: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>
Subject: possible unannotated irqs-off
Date: Tue, 14 Feb 2017 17:28:58 -0200
Message-ID: <20170214172858.07d4393a@darkbook.lan.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Realtek linux nic maintainers <nic_swsd@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:36592 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753972AbdBNT3I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:29:08 -0500
Received: by mail-qt0-f182.google.com with SMTP id k15so120247871qtg.3
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2017 11:29:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

This has been popping out in my machine since 4.9 (now using 4.10-rc5),
even before having VMware's modules loaded.

Please advise whether this is actually from RTL8169 or whether I should
post somewhere else (feel free to redirect, though).  Let me know if you
need more info and/or testing things.

Cheers,

====

[   93.509046] ------------[ cut here ]------------
[   93.509070] WARNING: CPU: 0 PID: 0 at kernel/locking/lockdep.c:3687 check_flags.part.45+0x1d8/0x1e0
[   93.509076] DEBUG_LOCKS_WARN_ON(current->hardirqs_enabled)
[   93.509078] Modules linked in: vmnet(O) vmmon(O)
[   93.509095] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O    4.10.0-rc5 #1
[   93.509100] Hardware name: Micro-Star International Co., Ltd. GX780/GT780/MS-1761, BIOS E1761IMS V3.01 05/02/2011
[   93.509105] Call Trace:
[   93.509111]  <IRQ>
[   93.509121]  dump_stack+0x99/0xd9
[   93.509130]  __warn+0xcb/0xf0
[   93.509137]  warn_slowpath_fmt+0x4f/0x60
[   93.509144]  check_flags.part.45+0x1d8/0x1e0
[   93.509150]  lock_acquire+0x1c1/0x270
[   93.509158]  _raw_spin_lock+0x41/0x80
[   93.509167]  ? jtcp_rcv_established+0x8e/0x2d0
[   93.509173]  jtcp_rcv_established+0x8e/0x2d0
[   93.509182]  tcp_v4_do_rcv+0x142/0x200
[   93.509189]  tcp_v4_rcv+0xae9/0xb80
[   93.509198]  ip_local_deliver_finish+0xba/0x390
[   93.509205]  ? ip_local_deliver_finish+0x26/0x390
[   93.509212]  ip_local_deliver+0x1b9/0x200
[   93.509218]  ? ip_local_deliver+0x58/0x200
[   93.509224]  ? ip_rcv_finish+0x680/0x680
[   93.509231]  ip_rcv_finish+0x1a0/0x680
[   93.509238]  ip_rcv+0x367/0x500
[   93.509243]  ? ip_rcv+0x277/0x500
[   93.509250]  ? inet_del_offload+0x40/0x40
[   93.509258]  __netif_receive_skb_core+0x5d3/0xd00
[   93.509265]  ? netif_receive_skb_internal+0x50/0x1d0
[   93.509271]  __netif_receive_skb+0x1d/0x60
[   93.509277]  netif_receive_skb_internal+0x9c/0x1d0
[   93.509283]  ? netif_receive_skb_internal+0x50/0x1d0
[   93.509289]  napi_gro_receive+0x155/0x220
[   93.509297]  rtl8169_poll+0x2c5/0x670
[   93.509304]  net_rx_action+0x1f0/0x440
[   93.509314]  __do_softirq+0x1d4/0x512
[   93.509322]  irq_exit+0xcb/0xd0
[   93.509329]  do_IRQ+0x71/0x130
[   93.509335]  common_interrupt+0x93/0x93
[   93.509347] RIP: 0010:cpuidle_enter_state+0xcf/0x400
[   93.509351] RSP: 0018:ffffffffb6403df0 EFLAGS: 00000286 ORIG_RAX: ffffffffffffffbd
[   93.509358] RAX: ffffffffb6428500 RBX: 0000000000000002 RCX: 000000000000001f
[   93.509363] RDX: 0000000000000001 RSI: ffffffffb62346a2 RDI: ffffffffb61ac1df
[   93.509367] RBP: ffffffffb6403e28 R08: 000000000000001f R09: 0000000000000000
[   93.509371] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000002
[   93.509375] R13: ffff9e46cdfe1ec8 R14: ffffffffb64f9338 R15: 00000015c4ad440d
[   93.509380]  </IRQ>
[   93.509391]  cpuidle_enter+0x17/0x20
[   93.509398]  call_cpuidle+0x23/0x50
[   93.509405]  do_idle+0x185/0x220
[   93.509413]  cpu_startup_entry+0x62/0x70
[   93.509420]  rest_init+0x131/0x140
[   93.509429]  start_kernel+0x466/0x473
[   93.509437]  ? early_idt_handler_array+0x120/0x120
[   93.509445]  x86_64_start_reservations+0x24/0x26
[   93.509453]  x86_64_start_kernel+0x142/0x14f
[   93.509462]  start_cpu+0x14/0x14
[   93.509469] ---[ end trace 2ca7dd51f09d19cd ]---
[   93.509473] possible reason: unannotated irqs-off.
[   93.509477] irq event stamp: 1437548
[   93.509487] hardirqs last  enabled at (1437548): [<ffffffffb504aafe>] kprobe_ftrace_handler+0x6e/0x1c0
[   93.509495] hardirqs last disabled at (1437547): [<ffffffffb504aade>] kprobe_ftrace_handler+0x4e/0x1c0
[   93.509503] softirqs last  enabled at (1437532): [<ffffffffb50ff621>] _local_bh_enable+0x21/0x50
[   93.509511] softirqs last disabled at (1437533): [<ffffffffb5100a3b>] irq_exit+0xcb/0xd0

-- 
Ricardo Nabinger Sanchez           http://rnsanchez.wait4.org/
        "You never learned anything by doing it right."
