From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Sun, 21 Mar 2010 18:26:27 -0700 (PDT)
Message-ID: <20100321.182627.214231065.davem@davemloft.net>
References: <20100319093210.GA23895@gondor.apana.org.au>
	<4BA349A8.9050105@iki.fi>
	<20100320151751.GB2950@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51495
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753578Ab0CVB0F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 21:26:05 -0400
In-Reply-To: <20100320151751.GB2950@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 20 Mar 2010 23:17:51 +0800

> Now Dave, my impression is that we picked the per-cpu design
> because it was the best data structure we had back in 2002,
> right?

Basically.

It was envisioned that flows at that level of detail would be spread
between different cpus, and that individual flows wouldn't propagate
onto multiple cpus much, if at all.  And if they did, no big deal we
have an entry in the cache of those cpus.

Do we know cases where it happens often?

In any event, RCU would certainly fit the bill just as easily and I
have no qualms against going in that direction.

Timo mentioned the socket overrides, we handle them at the top level
right before we look into the flow cache and I think it should stay
that way and we shouldn't bother tossing those into the flow cache at
all.  Just my humble opinion on this :-)
