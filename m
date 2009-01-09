From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Fri, 9 Jan 2009 16:15:00 +1100
Message-ID: <20090109051500.GA12836@gondor.apana.org.au>
References: <20090109041952.GA12087@gondor.apana.org.au> <4966DABD.1000203@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, rick.jones2@hp.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38415 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750940AbZAIFPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 00:15:14 -0500
Content-Disposition: inline
In-Reply-To: <4966DABD.1000203@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 12:03:57AM -0500, Jeff Garzik wrote:
>
> I think you misunderstand.  You don't have touch any drivers at all...  
> see attached demonstration patch.
>
> The more general point is that it is silly to add two ethtool ioctls  
> each time you want to twiddle a single boolean flag (whatever that flag  
> may be, generic or driver-specific or whatnot).
>
> If you still desire separation from ->{get,set}_flags() ops, then at  
> least create an ETHTOOL_[GS]STACK_FLAGS.

OK, however I'm still not convinced that this is a good idea.
First of all we don't have a shortage in the ethtool name space,
we've only used up two hex digits worth of a 32-bit integer field.

More importantly, making multiple bit changes at the same time
may create semantic nightmares in future.

For example, imagine if we started out with this generic flag
function and TX checksum offload, SG, TSO were done using it.
Now the user issues a request changing all of these bits, we'd
then have to either validate it for contradictory settings, or
devise some ad-hoc ordering in which the settings are applied.

This just seems to be unnecessary penny-pinching that doesn't
save much but may end up costing us down the road.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
