From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: BUG: sleeping function called from invalid context
Date: Sat, 28 Nov 2009 15:24:53 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911281520080.25587@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49711 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751107AbZK1NYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 08:24:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I booted up net-next-2.6 based kernel under kvm and keep getting this one:

BUG: sleeping function called from invalid context at mm/slub.c:1719
in_atomic(): 1, irqs_disabled(): 0, pid: 2847, name: dhclient3
1 lock held by dhclient3/2847:
 #0:  (rcu_read_lock){.+.+.+}, at: [<ffffffff813bf681>] packet_sendmsg_spkt+0x56/0x28b
Pid: 2847, comm: dhclient3 Not tainted 2.6.32-rc7-03467-g5e75659 #51
Call Trace:
 [<ffffffff8106a926>] ? __debug_show_held_locks+0x22/0x24
 [<ffffffff8103b405>] __might_sleep+0x126/0x12b
 [<ffffffff810d4b25>] kmem_cache_alloc+0x46/0x14e
 [<ffffffff812f9e7a>] __alloc_skb+0x3c/0x15b
 [<ffffffff812f4ffe>] sock_wmalloc+0x31/0x78
 [<ffffffff813bf732>] packet_sendmsg_spkt+0x107/0x28b
 [<ffffffff813bf681>] ? packet_sendmsg_spkt+0x56/0x28b
 [<ffffffff812f1c37>] sock_sendmsg+0xdf/0xf8
 [<ffffffff810d2389>] ? add_partial+0x1a/0x69
 [<ffffffff8105cd8e>] ? autoremove_wake_function+0x0/0x38
 [<ffffffff813e86d1>] ? _spin_unlock+0x30/0x4b
 [<ffffffff810d2389>] ? add_partial+0x1a/0x69
 [<ffffffff810d23d0>] ? add_partial+0x61/0x69
 [<ffffffff810d679b>] ? kmem_cache_free+0xcb/0x138
 [<ffffffff8106b539>] ? trace_hardirqs_on+0xd/0xf
 [<ffffffff812f34f8>] ? move_addr_to_kernel+0x40/0x49
 [<ffffffff812f35e0>] sys_sendto+0xdf/0x107
 [<ffffffff810f031c>] ? mntput_no_expire+0x24/0xf0
 [<ffffffff8100bbc2>] system_call_fastpath+0x16/0x1b


-- 
 i.
