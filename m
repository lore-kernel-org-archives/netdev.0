From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: attempt a single high order allocation
Date: Fri, 29 Aug 2014 20:29:23 -0700 (PDT)
Message-ID: <20140829.202923.1151165186886866910.davem@davemloft.net>
References: <1409154398.3173.69.camel@edumazet-glaptop2.roam.corp.google.com>
	<1409197774.3173.83.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rientjes@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750801AbaH3D3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 23:29:25 -0400
In-Reply-To: <1409197774.3173.83.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Aug 2014 20:49:34 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit ed98df3361f0 ("net: use __GFP_NORETRY for high order
> allocations") we tried to address one issue caused by order-3
> allocations.
> 
> We still observe high latencies and system overhead in situations where
> compaction is not successful.
> 
> Instead of trying order-3, order-2, and order-1, do a single order-3
> best effort and immediately fallback to plain order-0.
> 
> This mimics slub strategy to fallback to slab min order if the high
> order allocation used for performance failed.
> 
> Order-3 allocations give a performance boost only if they can be done
> without recurring and expensive memory scan.
> 
> Quoting David :
> 
> The page allocator relies on synchronous (sync light) memory compaction
> after direct reclaim for allocations that don't retry and deferred
> compaction doesn't work with this strategy because the allocation order
> is always decreasing from the previous failed attempt.
> 
> This means sync light compaction will always be encountered if memory
> cannot be defragmented or reclaimed several times during the
> skb_page_frag_refill() iteration.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Acked-by: David Rientjes <rientjes@google.com>

Applied, thanks Eric.

Do you want me to queue this up for -stable?
