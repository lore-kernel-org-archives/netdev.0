From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 15:34:42 -0800 (PST)
Message-ID: <20081217.153442.166884508.davem@davemloft.net>
References: <20081217221637.GA27811@gondor.apana.org.au>
	<20081217.151713.90960645.davem@davemloft.net>
	<20081217232553.GA28582@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, ptesarik@suse.cz, ilpo.jarvinen@helsinki.fi,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60570
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751906AbYLQXel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 18:34:41 -0500
In-Reply-To: <20081217232553.GA28582@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 18 Dec 2008 10:25:54 +1100

> 1) We don't support that right now.

I guess this is what the people writing RFC793 were thinking
as well :-)

> 2) Even if we did this would be broken either way because just
> where do you put the urgent pointer if your packet is > 64K and
> the urgent pointer lies in the packet but beyond 64K to the start?

You would need to chop up the packet to allow proper specification of
the URG pointer.

> > Given all of this I still think our current compromise is likely the
> > best one.  We never will advertise an URG pointer that is not pointing
> > to where the URG data will be in the sequence space.
> 
> I agree to the extent that urgent mode is hopelessly broken in
> so many ways so one more isn't going to make that much of a
> difference.
> 
> However, I still think that the approach suggested by Alexey is
> better than the status quo:
> 
> 1) It's unlikely to break any existing apps (all it does is send SIGURG
> multiple times).
> 
> 2) For those apps that use urgent mode in the first place, they're
> likely to want to see the urgent notification ASAP, rather than having
> it delayed due to the receiver being busy.  So this is an improvement
> over what we have.

I agree that prompt signalling of the URG condition is desirable.

None of the RFCs seem to give any real guidance in this area, and that
explains the plethora of ways we see various stacks handling this
situation.

I'll think about your patch some more, but no promises.
