From: David Miller <davem@davemloft.net>
Subject: Re: Rate Limitation of Router Reachability Probing for possible
 dead routers (is Re: ipv6: Do not depend on rt->n in rt6_probe().)
Date: Mon, 21 Jan 2013 15:44:25 -0500 (EST)
Message-ID: <20130121.154425.239941234471254414.davem@davemloft.net>
References: <20130121182858.GA8808@elgon.mountain>
	<50FD8BC6.1030509@linux-ipv6.org>
	<50FD96E4.1020607@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752262Ab3AUUo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 15:44:28 -0500
In-Reply-To: <50FD96E4.1020607@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 22 Jan 2013 04:28:36 +0900

> Ok, fix is easy, but in fact, we have broken router reachability
> probing.
> 
> Here rt->n was neighbour entry for (unreachable) router.
> The specification says, we SHOUDLD probe such router, but we
> should  have some rate limit (once per minute, or so).
> 
> We used "rt->n->updated" for this purpose, but now, if NS failed,
> we may immediately removes neighbour entry for it.  So,
> we might continue sending NS to dead router every 1 second.
> 
> Any ideas?

I don't see exactly how looking up the neigh on demand is different
from using a cached one in this context.

In both cases there should be a neigh entry in nd_tbl, why would
there not be one?

If necessary, you can decide to mark entries in such a way that
they would have a lower priority for neigh GC purging if that
is the issue.
