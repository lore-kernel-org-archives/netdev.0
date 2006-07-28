From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: aironet: "possible irq lock inversion dependency"
Date: Fri, 28 Jul 2006 00:59:18 -0400
Message-ID: <20060728045918.GB21441@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42168 "EHLO
	pickle.fieldses.org") by vger.kernel.org with ESMTP id S932575AbWG1E7T
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Jul 2006 00:59:19 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I get this when I bring up a network interface (a cisco aironet wireless
minipci card) on 2.6.18-rc2.

Let me know if any additonal information would be useful.

--b.


Jul 27 15:18:44 puzzle kernel: 
Jul 27 15:18:44 puzzle kernel: =========================================================
Jul 27 15:18:44 puzzle kernel: [ INFO: possible irq lock inversion dependency detected ]
Jul 27 15:18:44 puzzle kernel: ---------------------------------------------------------
Jul 27 15:18:44 puzzle kernel: pump/4811 just changed the state of lock:
Jul 27 15:18:44 puzzle kernel:  (&ai->aux_lock){+...}, at: [<c0427608>] airo_interrupt+0x3a8/0x1170
Jul 27 15:18:44 puzzle kernel: but this lock took another, hard-irq-unsafe lock in the past:
Jul 27 15:18:44 puzzle kernel:  (&skb_queue_lock_key){-+..}
Jul 27 15:18:44 puzzle kernel: 
Jul 27 15:18:44 puzzle kernel: and interrupts could create inverse lock ordering between them.
Jul 27 15:18:44 puzzle kernel: 
Jul 27 15:18:44 puzzle kernel: 
Jul 27 15:18:44 puzzle kernel: other info that might help us debug this:
Jul 27 15:18:44 puzzle kernel: 1 lock held by pump/4811:
Jul 27 15:18:44 puzzle kernel:  #0:  (&dev->_xmit_lock){-...}, at: [<c04fb7d6>] __qdisc_run+0x56/0x1c0
Jul 27 15:18:44 puzzle kernel: 
Jul 27 15:18:44 puzzle kernel: the first lock's dependencies:
Jul 27 15:18:44 puzzle kernel: -> (&ai->aux_lock){+...} ops: 2 {
Jul 27 15:18:44 puzzle kernel:    initial-use  at:
Jul 27 15:18:44 puzzle kernel:                         [<c013015a>] lock_acquire+0x5a/0x80
Jul 27 15:18:44 puzzle kernel:                         [<c056869e>] _spin_lock_irqsave+0x2e/0x40
Jul 27 15:18:44 puzzle kernel:                         [<c04271c4>] mpi_start_xmit+0x54/0xf0
Jul 27 15:18:44 puzzle kernel:                         [<c04eefe5>] dev_hard_start_xmit+0x205/0x2d0
Jul 27 15:18:44 puzzle kernel:                         [<c04fb7f4>] __qdisc_run+0x74/0x1c0
Jul 27 15:18:44 puzzle kernel:                         [<c04f09e5>] dev_queue_xmit+0x175/0x2f0
Jul 27 15:18:44 puzzle kernel:                         [<c05475b0>] packet_sendmsg+0x1e0/0x260
Jul 27 15:18:44 puzzle kernel:                         [<c04e3c4f>] sock_sendmsg+0xcf/0xf0
Jul 27 15:18:44 puzzle kernel:                         [<c04e4070>] sys_sendto+0xc0/0xf0
Jul 27 15:18:44 puzzle kernel:                         [<c04e5570>] sys_socketcall+0x140/0x1e0
Jul 27 15:18:44 puzzle kernel:                         [<c0102e37>] syscall_call+0x7/0xb
Jul 27 15:18:44 puzzle kernel:    in-hardirq-W at:
Jul 27 15:18:44 puzzle kernel:                         [<c013015a>] lock_acquire+0x5a/0x80
Jul 27 15:18:44 puzzle kernel:                         [<c056869e>] _spin_lock_irqsave+0x2e/0x40
Jul 27 15:18:44 puzzle kernel:                         [<c0427608>] airo_interrupt+0x3a8/0x1170
Jul 27 15:18:44 puzzle kernel:                         [<c013a807>] handle_IRQ_event+0x27/0x60
Jul 27 15:18:44 puzzle kernel:                         [<c013a8d4>] __do_IRQ+0x94/0x110
Jul 27 15:18:44 puzzle kernel:                         [<c0104c6a>] do_IRQ+0xaa/0xf0
Jul 27 15:18:44 puzzle kernel:                         [<c0103105>] common_interrupt+0x25/0x30
Jul 27 15:18:44 puzzle kernel:                         [<c04e9cce>] skb_release_data+0x4e/0x90
Jul 27 15:18:44 puzzle kernel:                         [<c04e9a8e>] kfree_skbmem+0xe/0x90
Jul 27 15:18:44 puzzle kernel:                         [<c04e9b6e>] __kfree_skb+0x5e/0xe0
Jul 27 15:18:44 puzzle kernel:                         [<c04e9c09>] kfree_skb+0x19/0x30
Jul 27 15:18:44 puzzle kernel:                         [<c04f01dc>] dev_kfree_skb_any+0x7c/0x90
Jul 27 15:18:44 puzzle kernel:                         [<c04238fc>] mpi_send_packet+0x12c/0x230
Jul 27 15:18:44 puzzle kernel:                         [<c0427210>] mpi_start_xmit+0xa0/0xf0
Jul 27 15:18:44 puzzle kernel:                         [<c04eefe5>] dev_hard_start_xmit+0x205/0x2d0
Jul 27 15:18:44 puzzle kernel:                         [<c04fb7f4>] __qdisc_run+0x74/0x1c0
Jul 27 15:18:44 puzzle kernel:                         [<c04f09e5>] dev_queue_xmit+0x175/0x2f0
Jul 27 15:18:44 puzzle kernel:                         [<c05475b0>] packet_sendmsg+0x1e0/0x260
Jul 27 15:18:44 puzzle kernel:                         [<c04e3c4f>] sock_sendmsg+0xcf/0xf0
Jul 27 15:18:44 puzzle kernel:                         [<c04e4070>] sys_sendto+0xc0/0xf0
Jul 27 15:18:44 puzzle kernel:                         [<c04e5570>] sys_socketcall+0x140/0x1e0
Jul 27 15:18:44 puzzle kernel:                         [<c0102e37>] syscall_call+0x7/0xb
Jul 27 15:18:44 puzzle kernel:  }
Jul 27 15:18:44 puzzle kernel:  ... key      at: [<c0abcb20>] __key.23102+0x0/0x8
Jul 27 15:18:44 puzzle kernel:  -> (&skb_queue_lock_key){-+..} ops: 2030 {
Jul 27 15:18:44 puzzle kernel:     initial-use  at:
Jul 27 15:18:44 puzzle kernel:                           [<c013015a>] lock_acquire+0x5a/0x80
Jul 27 15:18:44 puzzle kernel:                           [<c056869e>] _spin_lock_irqsave+0x2e/0x40
Jul 27 15:18:44 puzzle kernel:                           [<c04e8ce3>] skb_dequeue+0x13/0x60
Jul 27 15:18:44 puzzle kernel:                           [<c044ea58>] hpsbpkt_thread+0x48/0x90
Jul 27 15:18:44 puzzle kernel:                           [<c01293d4>] kthread+0xd4/0xe0
Jul 27 15:18:44 puzzle kernel:                           [<c0100c15>] kernel_thread_helper+0x5/0x10
Jul 27 15:18:44 puzzle kernel:     in-softirq-W at:
Jul 27 15:18:44 puzzle kernel:                           [<c013015a>] lock_acquire+0x5a/0x80
Jul 27 15:18:44 puzzle kernel:                           [<c056869e>] _spin_lock_irqsave+0x2e/0x40
Jul 27 15:18:44 puzzle kernel:                           [<c04e8c06>] skb_queue_tail+0x16/0x40
Jul 27 15:18:44 puzzle kernel:                           [<c04e82de>] sock_queue_rcv_skb+0xbe/0x130
Jul 27 15:18:44 puzzle kernel:                           [<c0524607>] udp_queue_rcv_skb+0x97/0x280
Jul 27 15:18:44 puzzle kernel:                           [<c052605b>] udp_rcv+0x2db/0x550
Jul 27 15:18:44 puzzle kernel:                           [<c0505477>] ip_local_deliver+0xe7/0x260
Jul 27 15:18:44 puzzle kernel:                           [<c0505197>] ip_rcv+0x277/0x470
Jul 27 15:18:44 puzzle kernel:                           [<c04eeb8d>] netif_receive_skb+0x16d/0x230
Jul 27 15:18:44 puzzle kernel:                           [<c04f055c>] process_backlog+0x8c/0x130
Jul 27 15:18:44 puzzle kernel:                           [<c04f0672>] net_rx_action+0x72/0x130
Jul 27 15:18:44 puzzle kernel:                           [<c011b4df>] __do_softirq+0x6f/0xe0
Jul 27 15:18:44 puzzle kernel:                           [<c0104b68>] do_softirq+0x88/0xe0
Jul 27 15:18:44 puzzle kernel:     hardirq-on-W at:
Jul 27 15:18:44 puzzle kernel:                           [<c013015a>] lock_acquire+0x5a/0x80
Jul 27 15:18:44 puzzle kernel:                           [<c056845a>] _spin_lock_bh+0x2a/0x40
Jul 27 15:18:44 puzzle kernel:                           [<c0524fb2>] udp_poll+0x52/0xf0
Jul 27 15:18:44 puzzle kernel:                           [<c04e3837>] sock_poll+0x17/0x20
Jul 27 15:18:44 puzzle kernel:                           [<c016efa2>] do_sys_poll+0x282/0x4d0
Jul 27 15:18:44 puzzle kernel:                           [<c016f21e>] sys_poll+0x2e/0x40
Jul 27 15:18:44 puzzle kernel:                           [<c0102e37>] syscall_call+0x7/0xb
Jul 27 15:18:44 puzzle kernel:   }
Jul 27 15:18:44 puzzle kernel:   ... key      at: [<c0ac6528>] skb_queue_lock_key+0x0/0x18
Jul 27 15:18:44 puzzle kernel:  ... acquired at:
Jul 27 15:18:44 puzzle kernel:    [<c013015a>] lock_acquire+0x5a/0x80
Jul 27 15:18:44 puzzle kernel:    [<c056869e>] _spin_lock_irqsave+0x2e/0x40
Jul 27 15:18:44 puzzle kernel:    [<c04e8c06>] skb_queue_tail+0x16/0x40
Jul 27 15:18:44 puzzle kernel:    [<c04271d6>] mpi_start_xmit+0x66/0xf0
Jul 27 15:18:44 puzzle kernel:    [<c04eefe5>] dev_hard_start_xmit+0x205/0x2d0
Jul 27 15:18:44 puzzle kernel:    [<c04fb7f4>] __qdisc_run+0x74/0x1c0
Jul 27 15:18:44 puzzle kernel:    [<c04f09e5>] dev_queue_xmit+0x175/0x2f0
Jul 27 15:18:44 puzzle kernel:    [<c05475b0>] packet_sendmsg+0x1e0/0x260
Jul 27 15:18:44 puzzle kernel:    [<c04e3c4f>] sock_sendmsg+0xcf/0xf0
Jul 27 15:18:44 puzzle kernel:    [<c04e4070>] sys_sendto+0xc0/0xf0
Jul 27 15:18:44 puzzle kernel:    [<c04e5570>] sys_socketcall+0x140/0x1e0
Jul 27 15:18:44 puzzle kernel:    [<c0102e37>] syscall_call+0x7/0xb
Jul 27 15:18:44 puzzle kernel: 
Jul 27 15:18:44 puzzle kernel: 
Jul 27 15:18:44 puzzle kernel: the second lock's dependencies:
Jul 27 15:18:44 puzzle kernel: -> (&skb_queue_lock_key){-+..} ops: 2030 {
Jul 27 15:18:44 puzzle kernel:    initial-use  at:
Jul 27 15:18:44 puzzle kernel:                         [<c013015a>] lock_acquire+0x5a/0x80
Jul 27 15:18:44 puzzle kernel:                         [<c056869e>] _spin_lock_irqsave+0x2e/0x40
Jul 27 15:18:44 puzzle kernel:                         [<c04e8ce3>] skb_dequeue+0x13/0x60
Jul 27 15:18:44 puzzle kernel:                         [<c044ea58>] hpsbpkt_thread+0x48/0x90
Jul 27 15:18:44 puzzle kernel:                         [<c01293d4>] kthread+0xd4/0xe0
Jul 27 15:18:44 puzzle kernel:                         [<c0100c15>] kernel_thread_helper+0x5/0x10
Jul 27 15:18:44 puzzle kernel:    in-softirq-W at:
Jul 27 15:18:44 puzzle kernel:                         [<c013015a>] lock_acquire+0x5a/0x80
Jul 27 15:18:44 puzzle kernel:                         [<c056869e>] _spin_lock_irqsave+0x2e/0x40
Jul 27 15:18:44 puzzle kernel:                         [<c04e8c06>] skb_queue_tail+0x16/0x40
Jul 27 15:18:44 puzzle kernel:                         [<c04e82de>] sock_queue_rcv_skb+0xbe/0x130
Jul 27 15:18:44 puzzle kernel:                         [<c0524607>] udp_queue_rcv_skb+0x97/0x280
Jul 27 15:18:44 puzzle kernel:                         [<c052605b>] udp_rcv+0x2db/0x550
Jul 27 15:18:44 puzzle kernel:                         [<c0505477>] ip_local_deliver+0xe7/0x260
Jul 27 15:18:44 puzzle kernel:                         [<c0505197>] ip_rcv+0x277/0x470
Jul 27 15:18:44 puzzle kernel:                         [<c04eeb8d>] netif_receive_skb+0x16d/0x230
Jul 27 15:18:44 puzzle kernel:                         [<c04f055c>] process_backlog+0x8c/0x130
Jul 27 15:18:44 puzzle kernel:                         [<c04f0672>] net_rx_action+0x72/0x130
Jul 27 15:18:44 puzzle kernel:                         [<c011b4df>] __do_softirq+0x6f/0xe0
Jul 27 15:18:44 puzzle kernel:                         [<c0104b68>] do_softirq+0x88/0xe0
Jul 27 15:18:44 puzzle kernel:    hardirq-on-W at:
Jul 27 15:18:44 puzzle kernel:                         [<c013015a>] lock_acquire+0x5a/0x80
Jul 27 15:18:44 puzzle kernel:                         [<c056845a>] _spin_lock_bh+0x2a/0x40
Jul 27 15:18:44 puzzle kernel:                         [<c0524fb2>] udp_poll+0x52/0xf0
Jul 27 15:18:44 puzzle kernel:                         [<c04e3837>] sock_poll+0x17/0x20
Jul 27 15:18:44 puzzle kernel:                         [<c016efa2>] do_sys_poll+0x282/0x4d0
Jul 27 15:18:44 puzzle kernel:                         [<c016f21e>] sys_poll+0x2e/0x40
Jul 27 15:18:44 puzzle kernel:                         [<c0102e37>] syscall_call+0x7/0xb
Jul 27 15:18:44 puzzle kernel:  }
Jul 27 15:18:44 puzzle kernel:  ... key      at: [<c0ac6528>] skb_queue_lock_key+0x0/0x18
Jul 27 15:18:44 puzzle kernel: 
Jul 27 15:18:44 puzzle kernel: stack backtrace:
Jul 27 15:18:44 puzzle kernel:  [<c0103799>] show_trace_log_lvl+0x119/0x140
Jul 27 15:18:44 puzzle kernel:  [<c0103da6>] show_trace+0x16/0x20
Jul 27 15:18:44 puzzle kernel:  [<c0103e7b>] dump_stack+0x1b/0x20
Jul 27 15:18:44 puzzle kernel:  [<c012e28f>] print_irq_inversion_bug+0xdf/0x110
Jul 27 15:18:44 puzzle kernel:  [<c012e4b3>] check_usage_forwards+0x33/0x40
Jul 27 15:18:44 puzzle kernel:  [<c012e590>] mark_lock+0xd0/0x550
Jul 27 15:18:44 puzzle kernel:  [<c012fa6c>] __lock_acquire+0x8bc/0xcb0
Jul 27 15:18:44 puzzle kernel:  [<c013015a>] lock_acquire+0x5a/0x80
Jul 27 15:18:44 puzzle kernel:  [<c056869e>] _spin_lock_irqsave+0x2e/0x40
Jul 27 15:18:44 puzzle kernel:  [<c0427608>] airo_interrupt+0x3a8/0x1170
Jul 27 15:18:44 puzzle kernel:  [<c013a807>] handle_IRQ_event+0x27/0x60
Jul 27 15:18:44 puzzle kernel:  [<c013a8d4>] __do_IRQ+0x94/0x110
Jul 27 15:18:44 puzzle kernel:  [<c0104c6a>] do_IRQ+0xaa/0xf0
Jul 27 15:18:44 puzzle kernel:  [<c0103105>] common_interrupt+0x25/0x30
Jul 27 15:18:44 puzzle kernel:  [<c01576d4>] kfree+0xa4/0xf0
Jul 27 15:18:44 puzzle kernel:  [<c04e9cce>] skb_release_data+0x4e/0x90
Jul 27 15:18:44 puzzle kernel:  [<c04e9a8e>] kfree_skbmem+0xe/0x90
Jul 27 15:18:44 puzzle kernel:  [<c04e9b6e>] __kfree_skb+0x5e/0xe0
Jul 27 15:18:44 puzzle kernel:  [<c04e9c09>] kfree_skb+0x19/0x30
Jul 27 15:18:44 puzzle kernel:  [<c04f01dc>] dev_kfree_skb_any+0x7c/0x90
Jul 27 15:18:44 puzzle kernel:  [<c04238fc>] mpi_send_packet+0x12c/0x230
Jul 27 15:18:44 puzzle kernel:  [<c0427210>] mpi_start_xmit+0xa0/0xf0
Jul 27 15:18:44 puzzle kernel:  [<c04eefe5>] dev_hard_start_xmit+0x205/0x2d0
Jul 27 15:18:44 puzzle kernel:  [<c04fb7f4>] __qdisc_run+0x74/0x1c0
Jul 27 15:18:44 puzzle kernel:  [<c04f09e5>] dev_queue_xmit+0x175/0x2f0
Jul 27 15:18:44 puzzle kernel:  [<c05475b0>] packet_sendmsg+0x1e0/0x260
Jul 27 15:18:44 puzzle kernel:  [<c04e3c4f>] sock_sendmsg+0xcf/0xf0
Jul 27 15:18:44 puzzle kernel:  [<c04e4070>] sys_sendto+0xc0/0xf0
Jul 27 15:18:44 puzzle kernel:  [<c04e5570>] sys_socketcall+0x140/0x1e0
Jul 27 15:18:44 puzzle kernel:  [<c0102e37>] syscall_call+0x7/0xb
Jul 27 15:18:44 puzzle kernel:  [<b7f0a8ec>] 0xb7f0a8ec
Jul 27 15:20:01 puzzle ntpd[4393]: synchronized to LOCAL(0), stratum 13
Jul 27 15:20:01 puzzle ntpd[4393]: kernel time sync disabled 0041
