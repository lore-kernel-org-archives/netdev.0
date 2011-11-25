From: igorm@etf.rs
Subject: [PATCH] Fix skb_update_prio
Date: Fri, 25 Nov 2011 18:44:53 +0100
Message-ID: <1322243094-10420-1-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
Cc: Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:58522 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753301Ab1KYRpJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Nov 2011 12:45:09 -0500
In-Reply-To: <igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Fixed warning

Nov 25 14:50:07 igor-PC kernel: [   94.864139]
Nov 25 14:50:07 igor-PC kernel: [   94.864143] ===============================
Nov 25 14:50:07 igor-PC kernel: [   94.864144] [ INFO: suspicious RCU usage. ]
Nov 25 14:50:07 igor-PC kernel: [   94.864146] -------------------------------
Nov 25 14:50:07 igor-PC kernel: [   94.864149] net/core/dev.c:2459 suspicious rcu_dereference_check() usage!
Nov 25 14:50:07 igor-PC kernel: [   94.864151]
Nov 25 14:50:07 igor-PC kernel: [   94.864151] other info that might help us debug this:
Nov 25 14:50:07 igor-PC kernel: [   94.864152]
Nov 25 14:50:07 igor-PC kernel: [   94.864153]
Nov 25 14:50:07 igor-PC kernel: [   94.864154] rcu_scheduler_active = 1, debug_locks = 1
Nov 25 14:50:07 igor-PC kernel: [   94.864156] 3 locks held by kworker/0:0/0:
Nov 25 14:50:07 igor-PC kernel: [   94.864158]  #0:  (&n->timer){+.-...}, at: [<c1074320>] call_timer_fn+0x0/0x2d0
Nov 25 14:50:07 igor-PC kernel: [   94.864168]  #1:  (&n->lock){++--..}, at: [<c156d3d8>] arp_solicit+0x228/0x300
Nov 25 14:50:07 igor-PC kernel: [   94.864173]  #2:  (rcu_read_lock_bh){.+....}, at: [<c14fdd10>] dev_queue_xmit+0x0/0x6e0
Nov 25 14:50:07 igor-PC kernel: [   94.864179]
Nov 25 14:50:07 igor-PC kernel: [   94.864180] stack backtrace:
Nov 25 14:50:07 igor-PC kernel: [   94.864183] Pid: 0, comm: kworker/0:0 Not tainted 3.2.0-rc2-net-next-mpls+ #13
Nov 25 14:50:07 igor-PC kernel: [   94.864185] Call Trace:
Nov 25 14:50:07 igor-PC kernel: [   94.864189]  [<c1617d55>] ? printk+0x2d/0x2f
Nov 25 14:50:07 igor-PC kernel: [   94.864194]  [<c109dfaa>] lockdep_rcu_suspicious+0xaa/0xc0
Nov 25 14:50:07 igor-PC kernel: [   94.864197]  [<c14fe17a>] dev_queue_xmit+0x46a/0x6e0
Nov 25 14:50:07 igor-PC kernel: [   94.864200]  [<c14fdd10>] ? dev_hard_start_xmit+0x650/0x650
Nov 25 14:50:07 igor-PC kernel: [   94.864203]  [<c156cc6f>] ? arp_create+0x1ff/0x220
Nov 25 14:50:07 igor-PC kernel: [   94.864205]  [<c156cf5d>] arp_xmit+0x1d/0x60
Nov 25 14:50:07 igor-PC kernel: [   94.864209]  [<c1516fd0>] ? eth_rebuild_header+0x80/0x80
Nov 25 14:50:07 igor-PC kernel: [   94.864211]  [<c156cff5>] arp_send+0x55/0x60
Nov 25 14:50:07 igor-PC kernel: [   94.864214]  [<c156d40a>] arp_solicit+0x25a/0x300
Nov 25 14:50:07 igor-PC kernel: [   94.864217]  [<c15041dd>] neigh_probe+0x3d/0x60
Nov 25 14:50:07 igor-PC kernel: [   94.864220]  [<c1506f5f>] neigh_timer_handler+0x16f/0x260
Nov 25 14:50:07 igor-PC kernel: [   94.864223]  [<c107439d>] call_timer_fn+0x7d/0x2d0
Nov 25 14:50:07 igor-PC kernel: [   94.864226]  [<c1074320>] ? init_timer_deferrable_key+0x20/0x20
Nov 25 14:50:07 igor-PC kernel: [   94.864230]  [<c1630837>] ? _raw_spin_unlock_irq+0x27/0x40
Nov 25 14:50:07 igor-PC kernel: [   94.864233]  [<c1506df0>] ? neigh_update+0x560/0x560
Nov 25 14:50:07 igor-PC kernel: [   94.864236]  [<c10746e0>] run_timer_softirq+0xf0/0x260
Nov 25 14:50:07 igor-PC kernel: [   94.864239]  [<c12e1802>] ? blk_done_softirq+0x42/0x80
Nov 25 14:50:07 igor-PC kernel: [   94.864242]  [<c106b6e0>] ? remote_softirq_receive+0x80/0x80
Nov 25 14:50:07 igor-PC kernel: [   94.864245]  [<c1506df0>] ? neigh_update+0x560/0x560
Nov 25 14:50:07 igor-PC kernel: [   94.864248]  [<c106b777>] __do_softirq+0x97/0x320
Nov 25 14:50:07 igor-PC kernel: [   94.864251]  [<c106b6e0>] ? remote_softirq_receive+0x80/0x80
Nov 25 14:50:07 igor-PC kernel: [   94.864252]  <IRQ>  [<c106bcd6>] ? irq_exit+0x86/0xb0
Nov 25 14:50:07 igor-PC kernel: [   94.864258]  [<c1639139>] ? smp_apic_timer_interrupt+0x59/0x88
Nov 25 14:50:07 igor-PC kernel: [   94.864262]  [<c12ff648>] ? trace_hardirqs_off_thunk+0xc/0x14
Nov 25 14:50:07 igor-PC kernel: [   94.864265]  [<c1631492>] ? apic_timer_interrupt+0x36/0x3c
Nov 25 14:50:07 igor-PC kernel: [   94.864269]  [<c103ac4a>] ? native_safe_halt+0xa/0x10
Nov 25 14:50:07 igor-PC kernel: [   94.864272]  [<c101cdf1>] ? default_idle.part.5+0x41/0x230
Nov 25 14:50:07 igor-PC kernel: [   94.864275]  [<c101cfff>] ? default_idle+0x1f/0x50
Nov 25 14:50:07 igor-PC kernel: [   94.864277]  [<c101d0da>] ? amd_e400_idle+0xaa/0x140
Nov 25 14:50:07 igor-PC kernel: [   94.864280]  [<c10146d6>] ? cpu_idle+0xb6/0x120
Nov 25 14:50:07 igor-PC kernel: [   94.864284]  [<c16103f2>] ? start_secondary+0x101/0x106

Just replaced function rcu_dereference with rcu_dereference_bh to avoid this warning
in function skb_update_prio
BR
Igor

Igor Maravic (1):
  Fix skb_update_prio

 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

-- 
1.7.5.4
