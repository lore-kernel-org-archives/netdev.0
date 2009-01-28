From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4]: net: Allow RX queue selection to seed TX queue
 hashing.
Date: Wed, 28 Jan 2009 12:22:31 -0800 (PST)
Message-ID: <20090128.122231.208600152.davem@davemloft.net>
References: <20090127.164027.245779962.davem@davemloft.net>
	<20090128085358.GA15593@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58525
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751565AbZA1UWe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 15:22:34 -0500
In-Reply-To: <20090128085358.GA15593@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 28 Jan 2009 19:53:58 +1100

> So can you think of a scenario where we really need this added
> protection?

No matter what you think about the randomness aspect, our
divide avoidance technique being used here will still
get in the way of the situations you seem to be concerned
about.

We do the jhash et al. magic in order to be able to use a
multiply to get the modulus.  So the function computing from
RX to TX queue numbers will never be straightforward.

And since we do need to do the jhash to make that multiply
trick work, the randomness comes essentially for free and
does not make the RX to TX queue relationship any more or
less straightforward.
