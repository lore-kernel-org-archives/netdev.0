From: David Miller <davem@davemloft.net>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 02 Oct 2012 22:55:35 -0400 (EDT)
Message-ID: <20121002.225535.1684530348122683084.davem@davemloft.net>
References: <1349121884.12401.721.camel@edumazet-glaptop>
	<1349192133.12401.768.camel@edumazet-glaptop>
	<1349192919.12401.778.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chris2553@googlemail.com, netdev@vger.kernel.org, gpiez@web.de,
	davej@redhat.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53249 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab2JCCzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2012 22:55:37 -0400
In-Reply-To: <1349192919.12401.778.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 02 Oct 2012 17:48:39 +0200

> [PATCH] ipv4: properly cache forward routes
> 
> commit d2d68ba9fe8 (ipv4: Cache input routes in fib_info nexthops.)
> introduced a regression for forwarding.
> 
> This was hard to reproduce but the symptom was that packets were
> delivered to local host instead of being forwarded.
> 
> Add a separate cache (nh_rth_forward) to solve the problem.
> 
> Many thanks to Chris Clayton for his patience and help.
> 
> Reported-by: Chris Clayton <chris2553@googlemail.com>
> Bisected-by: Chris Clayton <chris2553@googlemail.com>
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I'm still having trouble understanding how this can happen,
which is probably why I introduced this bug in the first
place :-)

Only INPUT routes created by ip_route_input_slow() cache using
nh_rth_input.

Routes for locally destinations vs. forwarded destinations will
resolve to different fib_info objects.

If at some point a new route is added which turns a local destination
into one for which we forward, normal invalidation of cached routes
ought to fix it.

There's some sequence of events I don't understand that causes the
corrupt route cache, can you show it to me?

Thanks.
