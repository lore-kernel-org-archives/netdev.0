From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH/RFC] ipv6: fib: Drop cached routes with dead neighbours
 on fib GC
Date: Thu, 10 Jan 2013 14:18:47 -0800 (PST)
Message-ID: <20130110.141847.265135906896223944.davem@davemloft.net>
References: <1357753459-12872-1-git-send-email-roland@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com
To: roland@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34340 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751987Ab3AJWSt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:18:49 -0500
In-Reply-To: <1357753459-12872-1-git-send-email-roland@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roland Dreier <roland@kernel.org>
Date: Wed,  9 Jan 2013 09:44:19 -0800

> When a bonding interface changes slaves (or goes from no active slaves
> to having a slave with link), the bonding driver generates a
> NETDEV_CHANGEADDR notification.  In this case, the ipv6 neighbour
> discovery code calls neigh_changeaddr(), which basically just calls
> neigh_flush_dev().
> 
> Now, neigh_flush_dev() just goes through the neighbour hash table and
> tries to free every neighbour from the device being flushed.  However,
> if someone else has an additional reference on the neighbour, we hit
 ...
> which leaves the final freeing of the "stray" neighbour until the last
> reference is dropped; in the meantime the output function is set to
> neigh_blackhole, which does nothing but free the skb and return ENETDOWN.

Another reason we must make ipv6 like ipv4, which looks up neighbours
on demand at packet output time rather than caching them in the route
entries.
