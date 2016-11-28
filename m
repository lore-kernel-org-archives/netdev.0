From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] ipv6: implement consistent hashing for
 equal-cost multipath routing
Date: Mon, 28 Nov 2016 15:32:09 -0500 (EST)
Message-ID: <20161128.153209.2135257061368558724.davem@davemloft.net>
References: <1480017556-25988-1-git-send-email-david.lebrun@uclouvain.be>
        <20161128.112248.2198395724649783009.davem@davemloft.net>
        <583C9093.7060404@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.lebrun@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41018 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751223AbcK1UcL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 15:32:11 -0500
In-Reply-To: <583C9093.7060404@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lebrun <david.lebrun@uclouvain.be>
Date: Mon, 28 Nov 2016 21:16:19 +0100

> The advantage of my solution over RFC2992 is lowest possible disruption
> and equal rebalancing of affected flows. The disadvantage is the lookup
> complexity of O(log n) vs O(1). Although from a theoretical viewpoint
> O(1) is obviously better, would O(log n) have an effectively measurable
> negative impact on scalability ? If we consider 32 next-hops for a route
> and 100 pseudo-random numbers generated per next-hop, the lookup
> algorithm would have to perform in the worst case log2 3200 = 11
> comparisons to select a next-hop for that route.

When I was working on the routing cache removal in ipv4 I compared
using a stupid O(1) hash lookup of the FIB entries vs. the O(log n)
fib_trie stuff actually in use.

It did make a difference.

This is a lookup that can be invoked 20 million times per second or
more.

Every cycle matters.

We already have a lot of trouble getting under the cycle budget one
has for routing at wire speed for very high link rates, please don't
make it worse.
