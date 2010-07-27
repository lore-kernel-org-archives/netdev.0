From: Johannes Berg <johannes@sipsolutions.net>
Subject: br_forward.c - rcu dereference warning
Date: Tue, 27 Jul 2010 12:45:53 +0200
Message-ID: <1280227553.3755.2.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:48848 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906Ab0G0Kpz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jul 2010 06:45:55 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <johannes@sipsolutions.net>)
	id 1OdhfW-0006p9-0U
	for netdev@vger.kernel.org; Tue, 27 Jul 2010 12:45:54 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I couldn't find this reported yet, apologies if I missed it.

johannes

[   60.140433] ===================================================
[   60.140437] [ INFO: suspicious rcu_dereference_check() usage. ]
[   60.140440] ---------------------------------------------------
[   60.140444] /home/johannes/sys/wireless-testing/net/bridge/br_forward.c:215 invoked rcu_dereference_check() without protection!
[   60.140447] 
[   60.140448] other info that might help us debug this:
[   60.140449] 
[   60.140452] 
[   60.140453] rcu_scheduler_active = 1, debug_locks = 1
[   60.140457] 2 locks held by Xorg/3083:
[   60.140459]  #0:  (&im->timer){+.-...}, at: [<ffffffff81058180>] call_timer_fn+0x0/0x2f0
[   60.140473]  #1:  (rcu_read_lock_bh){.+....}, at: [<ffffffff813b6c3a>] dev_queue_xmit+0x5a/0x690
[   60.140484] 
[   60.140484] stack backtrace:
[   60.140489] Pid: 3083, comm: Xorg Not tainted 2.6.35-rc6-wl-47665-gc2e2180-dirty #174
[   60.140492] Call Trace:
[   60.140495]  <IRQ>  [<ffffffff8107e494>] lockdep_rcu_dereference+0xa4/0xc0
[   60.140514]  [<ffffffffa07617c3>] br_multicast_flood+0x293/0x310 [bridge]
[   60.140531]  [<ffffffffa0761877>] br_multicast_deliver+0x17/0x20 [bridge]
[   60.140539]  [<ffffffffa07607bc>] br_dev_xmit+0x10c/0x170 [bridge]
[   60.140550]  [<ffffffff813b69ba>] dev_hard_start_xmit+0x21a/0x2e0
[   60.140556]  [<ffffffff813b708e>] dev_queue_xmit+0x4ae/0x690
[   60.140576]  [<ffffffff813c0d43>] neigh_resolve_output+0x113/0x250
[   60.140582]  [<ffffffff813eec46>] ip_finish_output+0x2a6/0x570
[   60.140588]  [<ffffffff813ef33c>] ip_mc_output+0x1dc/0x320
[   60.140593]  [<ffffffff813ed7ed>] ip_local_out+0x2d/0x80
[   60.140600]  [<ffffffff81422236>] igmp_send_report+0x1c6/0x200
[   60.140610]  [<ffffffff814238f0>] igmp_timer_expire+0x100/0x130
[   60.140615]  [<ffffffff81058219>] call_timer_fn+0x99/0x2f0
[   60.140636]  [<ffffffff810585e3>] run_timer_softirq+0x173/0x330
[   60.140641]  [<ffffffff8104f114>] __do_softirq+0x114/0x3d0
[   60.140652]  [<ffffffff8100360c>] call_softirq+0x1c/0x50


