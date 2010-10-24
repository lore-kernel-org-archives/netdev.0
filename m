From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: fix netlink_change_ngroups()
Date: Sun, 24 Oct 2010 16:26:23 -0700 (PDT)
Message-ID: <20101024.162623.68142530.davem@davemloft.net>
References: <1287930430.2658.805.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes@sipsolutions.net,
	paulmck@linux.vnet.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32878
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750996Ab0JXX0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Oct 2010 19:26:00 -0400
In-Reply-To: <1287930430.2658.805.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 24 Oct 2010 16:27:10 +0200

> commit 6c04bb18ddd633 (netlink: use call_rcu for netlink_change_ngroups)
> used a somewhat convoluted and racy way to perform call_rcu().
> 
> The old block of memory is freed after a grace period, but the rcu_head
> used to track it is located in new block.
> 
> This can clash if we call two times or more netlink_change_ngroups(),
> and a block is freed before another. call_rcu() called on different cpus
> makes no guarantee in order of callbacks.
> 
> Fix this using a more standard way of handling this : Each block of
> memory contains its own rcu_head, so that no 'use after free' can
> happens.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks a lot.
