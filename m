From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: only run neigh_forced_gc() from one cpu
Date: Wed, 19 Sep 2012 13:45:03 -0400 (EDT)
Message-ID: <20120919.134503.2070066674881117065.davem@davemloft.net>
References: <1348046827.26523.571.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maze@google.com, therbert@google.com,
	lorenzo@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55661 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932775Ab2ISRpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 13:45:05 -0400
In-Reply-To: <1348046827.26523.571.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 19 Sep 2012 11:27:07 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> With multiqueue NIC or RPS, we can have situation where all cpus are
> spending huge amount of cycles in neigh_forced_gc(), and machine can
> crash.
> 
> Since we are under probable attack, its better to let only one cpu
> do the scan, and other cpus immediately return from neigh_forced_gc()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I suspect you're only seeing this with ipv6 traffic present.

And you should mention that because it determines how we really
should handle this.

I seriously doubt you can trigger this with a pure-ipv4 workload
because all neigh entries are ref-less and thus trivially reclaimable.

If you can trigger it with ipv4, then reclaim needs to be rewritten so
that for ref-less entries it's more efficient and scalable.

I'm not applying this patch.
