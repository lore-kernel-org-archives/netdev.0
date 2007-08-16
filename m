From: Dave Jones <davej@redhat.com>
Subject: lockdep report in the bonding code.
Date: Thu, 16 Aug 2007 12:32:19 -0400
Message-ID: <20070816163219.GA1190@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:33916 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1764739AbXHPQcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 12:32:22 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l7GGWLVo030357
	for <netdev@vger.kernel.org>; Thu, 16 Aug 2007 12:32:21 -0400
Received: from gelk.kernelslacker.org (vpn-248-3.boston.redhat.com [10.13.248.3])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l7GGWK1v013538
	for <netdev@vger.kernel.org>; Thu, 16 Aug 2007 12:32:20 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.1/8.13.8) with ESMTP id l7GGWJPk001201
	for <netdev@vger.kernel.org>; Thu, 16 Aug 2007 12:32:19 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.1/8.14.1/Submit) id l7GGWJhQ001200
	for netdev@vger.kernel.org; Thu, 16 Aug 2007 12:32:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A Fedora users reported this against our 2.6.23-rc3 build

	Dave

NET: Registered protocol family 10
lo: Disabled Privacy Extensions
Ethernet Channel Bonding Driver: v3.1.3 (June 13, 2007)
bonding: MII link monitoring set to 100 ms
ADDRCONF(NETDEV_UP): bond0: link is not ready
bonding: bond0: Adding slave eth0.
e100: eth0: e100_watchdog: link up, 100Mbps, half-duplex
bonding: bond0: making interface eth0 the new active one.
bonding: bond0: enslaving eth0 as an active interface with an up link.
ADDRCONF(NETDEV_CHANGE): bond0: link becomes ready

=================================
[ INFO: inconsistent lock state ]
2.6.23-0.104.rc3.fc8 #1
---------------------------------
inconsistent {softirq-on-W} -> {in-softirq-W} usage.
events/0/9 [HC0[0]:SC1[2]:HE1:SE0] takes:
 (&(bond_info->tx_hashtbl_lock)){-+..}, at: [<f8ae4cc2>] bond_alb_xmit+0x26a/0x42c [bonding]
{softirq-on-W} state was registered at:
  [<c044a6e4>] __lock_acquire+0x4ff/0xc67
  [<c044b2c6>] lock_acquire+0x7b/0x9e
  [<c062ecc8>] _spin_lock+0x2e/0x58
  [<f8ae492e>] bond_alb_initialize+0x64/0x18e [bonding]
  [<f8ae1256>] bond_open+0x33/0x175 [bonding]
  [<c05ca8aa>] dev_open+0x31/0x6c
  [<c05c8a01>] dev_change_flags+0xa3/0x156
  [<c0609231>] devinet_ioctl+0x207/0x50e
  [<c06098df>] inet_ioctl+0x86/0xa4
  [<c05bec32>] sock_ioctl+0x1ac/0x1c9
  [<c0490b76>] do_ioctl+0x22/0x68
  [<c0490e05>] vfs_ioctl+0x249/0x25c
  [<c0490e61>] sys_ioctl+0x49/0x64
  [<c040519e>] syscall_call+0x7/0xb
  [<ffffffff>] 0xffffffff
irq event stamp: 266326
hardirqs last  enabled at (266326): [<c043258f>] local_bh_enable_ip+0xf3/0x106
hardirqs last disabled at (266325): [<c0432516>] local_bh_enable_ip+0x7a/0x106
softirqs last  enabled at (266306): [<c05e2d20>] rt_run_flush+0x6e/0x97
softirqs last disabled at (266309): [<c0407548>] do_softirq+0x74/0xf7

other info that might help us debug this:
3 locks held by events/0/9:
 #0:  (rtnl_mutex){--..}, at: [<c062d8a9>] mutex_lock+0x21/0x24
 #1:  (&bond->lock){-.-+}, at: [<f8ae4a90>] bond_alb_xmit+0x38/0x42c [bonding]
 #2:  (&bond->curr_slave_lock){..-+}, at: [<f8ae4a98>] bond_alb_xmit+0x40/0x42c [bonding]

stack backtrace:
 [<c04063d8>] show_trace_log_lvl+0x1a/0x2f
 [<c0406e71>] show_trace+0x12/0x14
 [<c0406e89>] dump_stack+0x16/0x18
 [<c0448f8a>] print_usage_bug+0x141/0x14b
 [<c0449810>] mark_lock+0x12f/0x472
 [<c044a66c>] __lock_acquire+0x487/0xc67
 [<c044b2c6>] lock_acquire+0x7b/0x9e
 [<c062ecc8>] _spin_lock+0x2e/0x58
 [<f8ae4cc2>] bond_alb_xmit+0x26a/0x42c [bonding]
 [<c05c9467>] dev_hard_start_xmit+0x21c/0x27a
 [<c05cb489>] dev_queue_xmit+0x1f7/0x2aa
 [<f8b274e0>] mld_sendpack+0x210/0x35a [ipv6]
 [<f8b28535>] mld_ifc_timer_expire+0x1e9/0x211 [ipv6]
 [<c0435a5f>] run_timer_softirq+0x127/0x18f
 [<c0432708>] __do_softirq+0x78/0xff
 [<c0407548>] do_softirq+0x74/0xf7
 [<c04325e6>] irq_exit+0x44/0x46
 [<c041d3a3>] smp_apic_timer_interrupt+0x74/0x81
 [<c0405cb7>] apic_timer_interrupt+0x33/0x38
 [<c062eba6>] _spin_unlock_bh+0x25/0x28
 [<c05e2d20>] rt_run_flush+0x6e/0x97
 [<c05e471c>] rt_cache_flush+0x7c/0xaf
 [<c060e86f>] fib_netdev_event+0x62/0x68
 [<c0630e6c>] notifier_call_chain+0x2b/0x4a
 [<c04391c8>] __raw_notifier_call_chain+0x19/0x1e
 [<c04391e7>] raw_notifier_call_chain+0x1a/0x1c
 [<c05c84f3>] netdev_state_change+0x20/0x31
 [<c05d251a>] __linkwatch_run_queue+0x159/0x183
 [<c05d2564>] linkwatch_event+0x20/0x27
 [<c043bd9b>] run_workqueue+0x7d/0x129
 [<c043c75b>] worker_thread+0xbb/0xc8
 [<c043ef6f>] kthread+0x3b/0x64
 [<c0405e5b>] kernel_thread_helper+0x7/0x10
 =======================
bonding: bond0: Adding slave eth1.
e100: eth1: e100_watchdog: link up, 100Mbps, half-duplex
bonding: bond0: enslaving eth1 as an active interface with an up link.
audit(1187170179.728:3): audit_pid=1885 old=0 by auid=4294967295
bond0: no IPv6 routers present

-- 
http://www.codemonkey.org.uk
