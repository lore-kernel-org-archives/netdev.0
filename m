From: Dave Jones <davej@redhat.com>
Subject: lockdep report from 2.6.20.5-rc1
Date: Wed, 4 Apr 2007 17:30:50 -0400
Message-ID: <20070404213050.GA19261@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:36532 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751894AbXDDVax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2007 17:30:53 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l34LUqFA030154
	for <netdev@vger.kernel.org>; Wed, 4 Apr 2007 17:30:52 -0400
Received: from gelk.kernelslacker.org (vpn-248-96.boston.redhat.com [10.13.248.96])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l34LUp9i023921
	for <netdev@vger.kernel.org>; Wed, 4 Apr 2007 17:30:52 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.13.8/8.13.8) with ESMTP id l34LUpBq021103
	for <netdev@vger.kernel.org>; Wed, 4 Apr 2007 17:30:51 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.13.8/8.13.8/Submit) id l34LUoLU021102
	for netdev@vger.kernel.org; Wed, 4 Apr 2007 17:30:50 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.20-1.2933.fc6debug #1
-------------------------------------------------------
swapper/0 is trying to acquire lock:
 (&tbl->lock){-+-+}, at: [<c05d5664>] neigh_lookup+0x43/0xa2

but task is already holding lock:
 (&list->lock#4){-+..}, at: [<c05d65c8>] neigh_proxy_process+0x20/0xc2

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&list->lock#4){-+..}:
       [<c043f4f2>] __lock_acquire+0x913/0xa43
       [<c043f933>] lock_acquire+0x56/0x6f
       [<c06325df>] _spin_lock_irqsave+0x34/0x44
       [<c05cbb87>] skb_dequeue+0x12/0x43
       [<c05cc9d4>] skb_queue_purge+0x14/0x1b
       [<c05d5b70>] neigh_update+0x349/0x3a5
       [<c060cd37>] arp_process+0x4d1/0x50a
       [<c060ce53>] arp_rcv+0xe3/0x100
       [<c05d0e43>] netif_receive_skb+0x2db/0x35a
       [<c05d2806>] process_backlog+0x95/0xf6
       [<c05d29ed>] net_rx_action+0xa1/0x1a8
       [<c042c1f6>] __do_softirq+0x6f/0xe2
       [<c04063c6>] do_softirq+0x61/0xd0
       [<ffffffff>] 0xffffffff

-> #1 (&n->lock){-+-+}:
       [<c043f4f2>] __lock_acquire+0x913/0xa43
       [<c043f933>] lock_acquire+0x56/0x6f
       [<c063231e>] _write_lock+0x2b/0x38
       [<c05d74b7>] neigh_periodic_timer+0x99/0x138
       [<c042f053>] run_timer_softirq+0x104/0x168
       [<c042c1f6>] __do_softirq+0x6f/0xe2
       [<c04063c6>] do_softirq+0x61/0xd0
       [<ffffffff>] 0xffffffff

-> #0 (&tbl->lock){-+-+}:
       [<c043f3f3>] __lock_acquire+0x814/0xa43
       [<c043f933>] lock_acquire+0x56/0x6f
       [<c06323d6>] _read_lock_bh+0x30/0x3d
       [<c05d5664>] neigh_lookup+0x43/0xa2
       [<c05d6317>] neigh_event_ns+0x2c/0x7a
       [<c060cbec>] arp_process+0x386/0x50a
       [<c060ce78>] parp_redo+0x8/0xa
       [<c05d660e>] neigh_proxy_process+0x66/0xc2
       [<c042f053>] run_timer_softirq+0x104/0x168
       [<c042c1f6>] __do_softirq+0x6f/0xe2
       [<c04063c6>] do_softirq+0x61/0xd0
       [<ffffffff>] 0xffffffff

other info that might help us debug this:

1 lock held by swapper/0:
 #0:  (&list->lock#4){-+..}, at: [<c05d65c8>] neigh_proxy_process+0x20/0xc2

stack backtrace:
 [<c04051dd>] show_trace_log_lvl+0x1a/0x2f
 [<c0405782>] show_trace+0x12/0x14
 [<c0405806>] dump_stack+0x16/0x18
 [<c043dcf5>] print_circular_bug_tail+0x5f/0x68
 [<c043f3f3>] __lock_acquire+0x814/0xa43
 [<c043f933>] lock_acquire+0x56/0x6f
 [<c06323d6>] _read_lock_bh+0x30/0x3d
 [<c05d5664>] neigh_lookup+0x43/0xa2
 [<c05d6317>] neigh_event_ns+0x2c/0x7a
 [<c060cbec>] arp_process+0x386/0x50a
 [<c060ce78>] parp_redo+0x8/0xa
 [<c05d660e>] neigh_proxy_process+0x66/0xc2
 [<c042f053>] run_timer_softirq+0x104/0x168
 [<c042c1f6>] __do_softirq+0x6f/0xe2
 [<c04063c6>] do_softirq+0x61/0xd0
 =======================


-- 
http://www.codemonkey.org.uk
