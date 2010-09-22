From: Andi Kleen <andi@firstfloor.org>
Subject: linux/netpoll.h:67 invoked rcu_dereference warning at boot
Date: Wed, 22 Sep 2010 15:20:15 +0200
Message-ID: <20100922132014.GA8853@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:49239 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab0IVNUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 09:20:17 -0400
Received: from basil.firstfloor.org (p5B3C9319.dip0.t-ipconnect.de [91.60.147.25])
	by one.firstfloor.org (Postfix) with ESMTP id 0336C1A98053
	for <netdev@vger.kernel.org>; Wed, 22 Sep 2010 15:20:15 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When booting a recent Linus tree with debugging enabled I get 
the following warning at boot.

I haven't looked into it closely.

-Andi

===================================================
[ INFO: suspicious rcu_dereference_check() usage. ]
---------------------------------------------------
/home/lsrc/git/linux-work2/include/linux/netpoll.h:67 invoked rcu_dereferenceeck() without protection!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 1
1 lock held by iceccd/2574:
 #0:  (sk_lock-AF_INET){+.+.+.}, at: [<ffffffff81721bf9>] udp_sendmsg+0x289/00

stack backtrace:
Pid: 2574, comm: iceccd Not tainted 2.6.36-rc4-00228-g5647824 #1
Call Trace:
 [<ffffffff81090a24>] lockdep_rcu_dereference+0xa4/0xc0
 [<ffffffff816d3475>] netif_rx+0x215/0x240
 [<ffffffff81135fbf>] ? cache_alloc_debugcheck_after+0x5f/0x280
 [<ffffffff8104cc61>] ? get_parent_ip+0x11/0x50
 [<ffffffff816d36b3>] netif_rx_ni+0x23/0x80
 [<ffffffff816fd3f3>] ip_dev_loopback_xmit+0x83/0xf0
 [<ffffffff816fddfa>] ip_mc_output+0x18a/0x220
 [<ffffffff816fd53d>] ip_local_out+0x2d/0x80
 [<ffffffff816ff414>] ip_push_pending_frames+0x284/0x420
 [<ffffffff81720586>] udp_push_pending_frames+0x146/0x3e0
 [<ffffffff81721bf9>] ? udp_sendmsg+0x289/0x720
 [<ffffffff81721de4>] udp_sendmsg+0x474/0x720
 [<ffffffff8105ec82>] ? local_bh_enable_ip+0x82/0x100
 [<ffffffff8172aee4>] inet_sendmsg+0xc4/0x160
 [<ffffffff8172ae20>] ? inet_sendmsg+0x0/0x160
 [<ffffffff816bddd0>] sock_sendmsg+0xc0/0xf0
 [<ffffffff8110e03a>] ? might_fault+0x7a/0xd0
 [<ffffffff8110e03a>] ? might_fault+0x7a/0xd0
 [<ffffffff8110e083>] ? might_fault+0xc3/0xd0
 [<ffffffff8110e03a>] ? might_fault+0x7a/0xd0
 [<ffffffff816bfe80>] ? move_addr_to_kernel+0x50/0x60
 [<ffffffff816c0ba5>] sys_sendto+0xf5/0x130
 [<ffffffff8100311b>] system_call_fastpath+0x16/0x1b


-- 
ak@linux.intel.com -- Speaking for myself only.
