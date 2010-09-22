From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Fw: rcu warning
Date: Wed, 22 Sep 2010 14:44:38 -0700
Message-ID: <20100922214438.GN2435@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:40532 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750913Ab0IVVon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Sep 2010 17:44:43 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8MLPTFE016883
	for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 17:25:29 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8MLifR7329438
	for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 17:44:41 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8MLieoD026498
	for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 17:44:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Date: Wed, 22 Sep 2010 13:52:28 -0700
> From: Andrew Morton <akpm@linux-foundation.org>
> To: "Paul E. McKenney" <paulmck@us.ibm.com>
> Subject: rcu warning
> X-Mailer: Sylpheed 2.4.8 (GTK+ 2.12.9; x86_64-pc-linux-gnu)
> 
> [   56.803750] 
> [   56.803752] ===================================================
> [   56.804082] [ INFO: suspicious rcu_dereference_check() usage. ]
> [   56.804249] ---------------------------------------------------
> [   56.804421] include/linux/inetdevice.h:219 invoked rcu_dereference_check() without protection!
> [   56.804708] 
> [   56.804709] other info that might help us debug this:
> [   56.804710] 
> [   56.805183] 
> [   56.805184] rcu_scheduler_active = 1, debug_locks = 1
> [   56.805501] 3 locks held by kworker/0:1/0:
> [   56.805664]  #0:  (&in_dev->mr_ifc_timer){+.-...}, at: [<ffffffff81042466>] run_timer_softirq+0xfd/0x226
> [   56.806126]  #1:  (&in_dev->mc_list_lock){++.-..}, at: [<ffffffff8133e81d>] igmp_ifc_timer_expire+0x2a/0x221
> [   56.806588]  #2:  (&(&im->lock)->rlock){+.-...}, at: [<ffffffff8133e948>] igmp_ifc_timer_expire+0x155/0x221
> [   56.807043] 
> [   56.807044] stack backtrace:
> [   56.807364] Pid: 0, comm: kworker/0:1 Not tainted 2.6.36-rc5-mm1 #1
> [   56.807561] Call Trace:
> [   56.807723]  <IRQ>  [<ffffffff8105b88b>] lockdep_rcu_dereference+0x99/0xa2
> [   56.807948]  [<ffffffff8130dc66>] __ip_route_output_key+0x34f/0xb19
> [   56.808120]  [<ffffffff8130d94a>] ? __ip_route_output_key+0x33/0xb19
> [   56.814367]  [<ffffffff8130e453>] ip_route_output_flow+0x23/0x1ee
> [   56.814536]  [<ffffffff8130e62c>] ip_route_output_key+0xe/0x10
> [   56.814704]  [<ffffffff8133e19d>] igmpv3_newpack+0x7f/0x1c2
> [   56.814873]  [<ffffffff8133e30d>] add_grhead+0x2d/0x94
> [   56.815039]  [<ffffffff8133e6c2>] add_grec+0x34e/0x38c
> [   56.815206]  [<ffffffff8133e9a8>] igmp_ifc_timer_expire+0x1b5/0x221
> [   56.815375]  [<ffffffff810424e8>] run_timer_softirq+0x17f/0x226
> [   56.815547]  [<ffffffff81042466>] ? run_timer_softirq+0xfd/0x226
> [   56.815715]  [<ffffffff8133e7f3>] ? igmp_ifc_timer_expire+0x0/0x221
> [   56.815885]  [<ffffffff8103ca8f>] __do_softirq+0xa5/0x13a
> [   56.816051]  [<ffffffff8100390c>] call_softirq+0x1c/0x28
> [   56.816219]  [<ffffffff81004eba>] do_softirq+0x38/0x82
> [   56.816385]  [<ffffffff8103c9e8>] irq_exit+0x47/0x49
> [   56.816553]  [<ffffffff81019ce3>] smp_apic_timer_interrupt+0x88/0x96
> [   56.816722]  [<ffffffff810033d3>] apic_timer_interrupt+0x13/0x20
> [   56.816888]  <EOI>  [<ffffffff8138607a>] ? __atomic_notifier_call_chain+0x0/0x84
> [   56.817215]  [<ffffffff81009a9b>] ? mwait_idle+0x65/0x71
> [   56.817382]  [<ffffffff81009a91>] ? mwait_idle+0x5b/0x71
> [   56.817549]  [<ffffffff810014ca>] cpu_idle+0x48/0x66
> [   56.817716]  [<ffffffff8137b4da>] start_secondary+0x1b9/0x1bd
> [   56.817883]  [<ffffffff8137b321>] ? start_secondary+0x0/0x1bd

Hello, Eric,

In linux/master, there is an rcu_read_lock_bh() in the call path, but
an rcu_dereference() instead of an rcu_dereference_bh().  Thoughts?

(I have asked Andrew what kernel this is against -- I don't see the
rcu_read_lock() that I would expect to see in the lockdep output.)

							Thanx, Paul

> We seem to be getting way too many of these.
> 
> ----- End forwarded message -----
