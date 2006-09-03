From: Dave Jones <davej@redhat.com>
Subject: neigh_lookup lockdep warning
Date: Sat, 2 Sep 2006 21:26:59 -0400
Message-ID: <20060903012659.GA28183@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:6548 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751855AbWICB1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2006 21:27:14 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k831REIm030344
	for <netdev@vger.kernel.org>; Sat, 2 Sep 2006 21:27:14 -0400
Received: from nwo.kernelslacker.org (vpn-248-6.boston.redhat.com [10.13.248.6])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k831R8Rg021746
	for <netdev@vger.kernel.org>; Sat, 2 Sep 2006 21:27:11 -0400
Received: from nwo.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by nwo.kernelslacker.org (8.13.8/8.13.7) with ESMTP id k831R2et028799
	for <netdev@vger.kernel.org>; Sat, 2 Sep 2006 21:27:02 -0400
Received: (from davej@localhost)
	by nwo.kernelslacker.org (8.13.8/8.13.8/Submit) id k831QxjA028798
	for netdev@vger.kernel.org; Sat, 2 Sep 2006 21:26:59 -0400
To: netdev <netdev@vger.kernel.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Seen during boot of a 2.6.18rc5-git1 based kernel.

		Dave

=======================================================
[ INFO: possible circular locking dependency detected ]
2.6.17-1.2608.fc6 #1
-------------------------------------------------------
swapper/0 is trying to acquire lock:
 (&tbl->lock){-+-+}, at: [<c05bdf97>] neigh_lookup+0x50/0xaf

but task is already holding lock:
 (&list->lock#3){-+..}, at: [<c05bf677>] neigh_proxy_process+0x20/0xc2

which lock already depends on the new lock.


the existing dependency chain (in reverse order) is:

-> #2 (&list->lock#3){-+..}:
       [<c043c09a>] lock_acquire+0x4b/0x6d
       [<c061411f>] _spin_lock_irqsave+0x22/0x32
       [<c05b451f>] skb_dequeue+0x12/0x43
       [<c05b523a>] skb_queue_purge+0x14/0x1b
       [<c05be990>] neigh_update+0x34a/0x3a6
       [<c05f0f6e>] arp_process+0x4ad/0x4e7
       [<c05f107c>] arp_rcv+0xd4/0xf1
       [<c05b942c>] netif_receive_skb+0x205/0x274
       [<c7bb0566>] rhine_napipoll+0x28d/0x449 [via_rhine]
       [<c05baf73>] net_rx_action+0x9d/0x196
       [<c04293a7>] __do_softirq+0x78/0xf2
       [<c0406673>] do_softirq+0x5a/0xbe

-> #1 (&n->lock){-+..}:
       [<c043c09a>] lock_acquire+0x4b/0x6d
       [<c0613e48>] _write_lock+0x19/0x28
       [<c05bfc69>] neigh_periodic_timer+0x98/0x13c
       [<c042dc58>] run_timer_softirq+0x108/0x167
       [<c04293a7>] __do_softirq+0x78/0xf2
       [<c0406673>] do_softirq+0x5a/0xbe

-> #0 (&tbl->lock){-+-+}:
       [<c043c09a>] lock_acquire+0x4b/0x6d
       [<c0613f02>] _read_lock_bh+0x1e/0x2d
       [<c05bdf97>] neigh_lookup+0x50/0xaf
       [<c05bf0b9>] neigh_event_ns+0x2c/0x77
       [<c05f0e2a>] arp_process+0x369/0x4e7
       [<c05f10a1>] parp_redo+0x8/0xa
       [<c05bf6bd>] neigh_proxy_process+0x66/0xc2
       [<c042dc58>] run_timer_softirq+0x108/0x167
       [<c04293a7>] __do_softirq+0x78/0xf2
       [<c0406673>] do_softirq+0x5a/0xbe

other info that might help us debug this:

1 lock held by swapper/0:
 #0:  (&list->lock#3){-+..}, at: [<c05bf677>] neigh_proxy_process+0x20/0xc2

stack backtrace:
 [<c04051ee>] show_trace_log_lvl+0x58/0x159
 [<c04057ea>] show_trace+0xd/0x10
 [<c0405903>] dump_stack+0x19/0x1b
 [<c043b182>] print_circular_bug_tail+0x59/0x64
 [<c043b99a>] __lock_acquire+0x80d/0x99c
 [<c043c09a>] lock_acquire+0x4b/0x6d
 [<c0613f02>] _read_lock_bh+0x1e/0x2d
 [<c05bdf97>] neigh_lookup+0x50/0xaf
 [<c05bf0b9>] neigh_event_ns+0x2c/0x77
 [<c05f0e2a>] arp_process+0x369/0x4e7
 [<c05f10a1>] parp_redo+0x8/0xa
 [<c05bf6bd>] neigh_proxy_process+0x66/0xc2
 [<c042dc58>] run_timer_softirq+0x108/0x167
 [<c04293a7>] __do_softirq+0x78/0xf2
 [<c0406673>] do_softirq+0x5a/0xbe
 [<c0429250>] irq_exit+0x3d/0x3f
 [<c0417cbf>] smp_apic_timer_interrupt+0x79/0x7e
 [<c0404b0a>] apic_timer_interrupt+0x2a/0x30
DWARF2 unwinder stuck at apic_timer_interrupt+0x2a/0x30
Leftover inexact backtrace:

-- 
http://www.codemonkey.org.uk

-- 
VGER BF report: U 0.489161
