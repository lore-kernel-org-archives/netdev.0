From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: 2.6.30-07769: BUG: MAX_STACK_TRACE_ENTRIES too low! (tcp/dma)
Date: Mon, 22 Jun 2009 12:46:15 +0400
Message-ID: <a4423d670906220146t4601cf1eq2a6cd9cd70cc728c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f213.google.com ([209.85.218.213]:59411 "EHLO
	mail-bw0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168AbZFVIqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 04:46:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rsync triggers this big stack trace.

BUG: MAX_STACK_TRACE_ENTRIES too low!
turning off the locking correctness validator.
Pid: 1865, comm: rsync Not tainted 2.6.30-07769-gf234012 #1
Call Trace:
 [<ffffffff81080622>] save_trace+0xc2/0xe0
 [<ffffffff810806a7>] add_lock_to_list+0x67/0x110
 [<ffffffff81082721>] ? check_irq_usage+0xb1/0x110
 [<ffffffff812f5e00>] ? add_dma_entry+0x50/0xa0
 [<ffffffff81084b68>] __lock_acquire+0xe98/0x1250
 [<ffffffff810690a8>] ? __kernel_text_address+0x78/0xa0
 [<ffffffff812f5e00>] ? add_dma_entry+0x50/0xa0
 [<ffffffff81084fc0>] lock_acquire+0xa0/0xe0
 [<ffffffff812f5e00>] ? add_dma_entry+0x50/0xa0
 [<ffffffff814eb11d>] _spin_lock_irqsave+0x5d/0xb0
 [<ffffffff812f5e00>] ? add_dma_entry+0x50/0xa0
 [<ffffffff81083330>] ? trace_hardirqs_on+0x20/0x40
 [<ffffffff812f5e00>] add_dma_entry+0x50/0xa0
 [<ffffffff812f75d9>] debug_dma_map_page+0x129/0x190
 [<ffffffff81451f9e>] skb_dma_map+0xee/0x3c0
 [<ffffffff813d8a3a>] bnx2_start_xmit+0x11a/0x4a0
 [<ffffffff814569e8>] dev_hard_start_xmit+0x2a8/0x370
 [<ffffffff814eaf57>] ? _spin_lock+0x77/0xa0
 [<ffffffff8146c66e>] __qdisc_run+0x27e/0x2d0
 [<ffffffff814eaf57>] ? _spin_lock+0x77/0xa0
 [<ffffffff81456ed8>] dev_queue_xmit+0x2c8/0x4a0
 [<ffffffff8147e3cf>] ip_finish_output+0x12f/0x370
 [<ffffffff8147e6bb>] ip_output+0xab/0xe0
 [<ffffffff814459ef>] ? lock_sock_nested+0x4f/0x140
 [<ffffffff8147b4c7>] ip_local_out+0x77/0xa0
 [<ffffffff8147c50c>] ip_queue_xmit+0x23c/0x450
 [<ffffffff81082ec8>] ? mark_held_locks+0x78/0xb0
 [<ffffffff810832ad>] ? trace_hardirqs_on_caller+0x17d/0x1e0
 [<ffffffff814945e5>] tcp_transmit_skb+0x515/0x800
 [<ffffffff81494ab6>] tcp_send_ack+0xe6/0x130
 [<ffffffff81484e55>] tcp_cleanup_rbuf+0x75/0x150
 [<ffffffff81487a1c>] tcp_recvmsg+0x5ac/0xf40
 [<ffffffff810850a2>] ? lock_release_non_nested+0xa2/0x2f0
 [<ffffffff810bbb1a>] ? might_fault+0x8a/0xf0
 [<ffffffff81444ac1>] sock_common_recvmsg+0x41/0x70
 [<ffffffff81440e42>] sock_aio_read+0x152/0x160
 [<ffffffff810efcfe>] ? set_fd_set+0x4e/0x80
 [<ffffffff810dd4b1>] do_sync_read+0x101/0x160
 [<ffffffff8106c370>] ? autoremove_wake_function+0x0/0x60
 [<ffffffff81070b91>] ? ktime_get_ts+0x71/0x90
 [<ffffffff810efb07>] ? poll_select_copy_remaining+0x117/0x170
 [<ffffffff810dde26>] vfs_read+0x196/0x1a0
 [<ffffffff810ddf4f>] sys_read+0x5f/0xc0
 [<ffffffff8100b9ab>] system_call_fastpath+0x16/0x1b
