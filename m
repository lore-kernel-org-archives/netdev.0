From: Dave Jones <davej@redhat.com>
Subject: BUG: held lock freed!  (udp_queue_rcv_skb)
Date: Tue, 10 Dec 2013 19:39:48 -0500
Message-ID: <20131211003948.GA18825@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21865 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751257Ab3LKAkL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 19:40:11 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id rBB0eAbn020334
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 19:40:11 -0500
Received: from gelk.kernelslacker.org (ovpn-113-108.phx2.redhat.com [10.3.113.108])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id rBB0dwUa022082
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 19:40:08 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.7/8.14.7) with ESMTP id rBB0dt5b018949
	for <netdev@vger.kernel.org>; Tue, 10 Dec 2013 19:39:56 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.7/8.14.7/Submit) id rBB0dmFp018934
	for netdev@vger.kernel.org; Tue, 10 Dec 2013 19:39:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My router just hit this on Linus' current tree.

	Dave

[ 5059.434216] =========================
[ 5059.434314] [ BUG: held lock freed! ]
[ 5059.434420] 3.13.0-rc3+ #9 Not tainted
[ 5059.434520] -------------------------
[ 5059.434620] named/863 is freeing memory ffff88005e960000-ffff88005e96061f, with a lock still held there!
[ 5059.434815]  (slock-AF_INET){+.-...}, at: [<ffffffff8149bd21>] udp_queue_rcv_skb+0xd1/0x4b0
[ 5059.435012] 3 locks held by named/863:
[ 5059.435086]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff8143054d>] __netif_receive_skb_core+0x11d/0x940
[ 5059.435295]  #1:  (rcu_read_lock){.+.+..}, at: [<ffffffff81467a5e>] ip_local_deliver_finish+0x3e/0x410
[ 5059.435500]  #2:  (slock-AF_INET){+.-...}, at: [<ffffffff8149bd21>] udp_queue_rcv_skb+0xd1/0x4b0
[ 5059.435734] 
stack backtrace:
[ 5059.435858] CPU: 0 PID: 863 Comm: named Not tainted 3.13.0-rc3+ #9 [loadavg: 0.21 0.06 0.06 1/115 1365]
[ 5059.436052] Hardware name:                  /D510MO, BIOS MOPNV10J.86A.0175.2010.0308.0620 03/08/2010
[ 5059.436223]  0000000000000002 ffff88007e203ad8 ffffffff8153a372 ffff8800677130e0
[ 5059.436390]  ffff88007e203b10 ffffffff8108cafa ffff88005e960000 ffff88007b00cfc0
[ 5059.436554]  ffffea00017a5800 ffffffff8141c490 0000000000000246 ffff88007e203b48
[ 5059.436718] Call Trace:
[ 5059.436769]  <IRQ>  [<ffffffff8153a372>] dump_stack+0x4d/0x66
[ 5059.436904]  [<ffffffff8108cafa>] debug_check_no_locks_freed+0x15a/0x160
[ 5059.437037]  [<ffffffff8141c490>] ? __sk_free+0x110/0x230
[ 5059.437147]  [<ffffffff8112da2a>] kmem_cache_free+0x6a/0x150
[ 5059.437260]  [<ffffffff8141c490>] __sk_free+0x110/0x230
[ 5059.437364]  [<ffffffff8141c5c9>] sk_free+0x19/0x20
[ 5059.437463]  [<ffffffff8141cb25>] sock_edemux+0x25/0x40
[ 5059.437567]  [<ffffffff8141c181>] sock_queue_rcv_skb+0x81/0x280
[ 5059.437685]  [<ffffffff8149bd21>] ? udp_queue_rcv_skb+0xd1/0x4b0
[ 5059.437805]  [<ffffffff81499c82>] __udp_queue_rcv_skb+0x42/0x240
[ 5059.437925]  [<ffffffff81541d25>] ? _raw_spin_lock+0x65/0x70
[ 5059.438038]  [<ffffffff8149bebb>] udp_queue_rcv_skb+0x26b/0x4b0
[ 5059.438155]  [<ffffffff8149c712>] __udp4_lib_rcv+0x152/0xb00
[ 5059.438269]  [<ffffffff8149d7f5>] udp_rcv+0x15/0x20
[ 5059.438367]  [<ffffffff81467b2f>] ip_local_deliver_finish+0x10f/0x410
[ 5059.438492]  [<ffffffff81467a5e>] ? ip_local_deliver_finish+0x3e/0x410
[ 5059.438621]  [<ffffffff81468653>] ip_local_deliver+0x43/0x80
[ 5059.438733]  [<ffffffff81467f70>] ip_rcv_finish+0x140/0x5a0
[ 5059.438843]  [<ffffffff81468926>] ip_rcv+0x296/0x3f0
[ 5059.438945]  [<ffffffff81430b72>] __netif_receive_skb_core+0x742/0x940
[ 5059.439074]  [<ffffffff8143054d>] ? __netif_receive_skb_core+0x11d/0x940
[ 5059.442231]  [<ffffffff8108c81d>] ? trace_hardirqs_on+0xd/0x10
[ 5059.442231]  [<ffffffff81430d83>] __netif_receive_skb+0x13/0x60
[ 5059.442231]  [<ffffffff81431c1e>] netif_receive_skb+0x1e/0x1f0
[ 5059.442231]  [<ffffffff814334e0>] napi_gro_receive+0x70/0xa0
[ 5059.442231]  [<ffffffffa01de426>] rtl8169_poll+0x166/0x700 [r8169]
[ 5059.442231]  [<ffffffff81432bc9>] net_rx_action+0x129/0x1e0
[ 5059.442231]  [<ffffffff810478cd>] __do_softirq+0xed/0x240
[ 5059.442231]  [<ffffffff81047e25>] irq_exit+0x125/0x140
[ 5059.442231]  [<ffffffff81004241>] do_IRQ+0x51/0xc0
[ 5059.442231]  [<ffffffff81542bef>] common_interrupt+0x6f/0x6f
[ 5059.442231]  <EOI>  [<ffffffff814a7280>] ? inet_autobind+0x60/0x60
[ 5059.442231]  [<ffffffff8141722a>] ? SYSC_connect+0xea/0x130
[ 5059.442231]  [<ffffffff810cf484>] ? __audit_syscall_entry+0x94/0xf0
[ 5059.442231]  [<ffffffff810cf484>] ? __audit_syscall_entry+0x94/0xf0
[ 5059.442231]  [<ffffffff8100d4be>] ? syscall_trace_enter+0x16e/0x190
[ 5059.442231]  [<ffffffff81418549>] SyS_connect+0x9/0x10
[ 5059.442231]  [<ffffffff81549c34>] tracesys+0xdd/0xe2
