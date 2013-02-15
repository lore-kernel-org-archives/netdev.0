From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tipc: fix missing spinlock init in broadcast code
Date: Fri, 15 Feb 2013 15:41:22 -0500 (EST)
Message-ID: <20130215.154122.2016353281507345149.davem@davemloft.net>
References: <1360889013-4394-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, erik.hugne@ericsson.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44479 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734Ab3BOUlY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Feb 2013 15:41:24 -0500
In-Reply-To: <1360889013-4394-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Thu, 14 Feb 2013 19:43:33 -0500

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> After commit 3c294cb3 "tipc: remove the bearer congestion mechanism",
> we try to grab the broadcast bearer lock when sending multicast
> messages over the broadcast link. This will cause an oops because
> the lock is never initialized. This is an old bug, but the lock
> was never actually used before commit 3c294cb3, so that why it was
> not visible until now.  The oops will look something like:
> 
> 	BUG: spinlock bad magic on CPU#2, daemon/147
> 	lock: bcast_bearer+0x48/0xffffffffffffd19a [tipc],
> 	.magic: 00000000, .owner: <none>/-1, .owner_cpu: 0
> 	Pid: 147, comm: daemon Not tainted 3.8.0-rc3+ #206
> 	Call Trace:
> 	spin_dump+0x8a/0x8f
> 	spin_bug+0x21/0x26
> 	do_raw_spin_lock+0x114/0x150
> 	_raw_spin_lock_bh+0x19/0x20
> 	tipc_bearer_blocked+0x1f/0x40 [tipc]
> 	tipc_link_send_buf+0x82/0x280 [tipc]
> 	? __alloc_skb+0x9f/0x2b0
> 	tipc_bclink_send_msg+0x77/0xa0 [tipc]
> 	tipc_multicast+0x11b/0x1b0 [tipc]
> 	send_msg+0x225/0x530 [tipc]
> 	sock_sendmsg+0xca/0xe0
> 
> The above can be triggered by running the multicast demo program.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>

Applied, thanks.
