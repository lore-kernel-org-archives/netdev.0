From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] ipv4: Initialize on-stack cork more efficiently.
Date: Fri, 06 May 2011 22:21:25 -0700 (PDT)
Message-ID: <20110506.222125.193720006.davem@davemloft.net>
References: <20110506.152623.232747437.davem@davemloft.net>
	<1304721317.2821.156.camel@edumazet-laptop>
	<1304745104.2821.590.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45685
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751675Ab1EGFV5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 01:21:57 -0400
In-Reply-To: <1304745104.2821.590.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 07 May 2011 07:11:44 +0200

> By the way, when I spotted this "struct inet_cork cork = {};" to be
> optimized, my idea was to add yet another case of fastpath to UDP send :
> 
> For small datagrams (most UDP uses : RTP, DNS...),
> perform the user->kernel copy before route lookup, so that we can
> perform an RCU route lookup. This would tremendously speedup UDP, since
> the refcount handling is our last hot spot (not counting qdisc if
> present)

Interesting idea.

This reminds me, remember about the input noref route lookup stuff
going away with the routing cache removal?  It turns out that when we
do my "routes embedded in fib nexthop" for input, the noref stuff can
be used. :)

