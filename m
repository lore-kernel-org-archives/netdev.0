From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Make possible speeds known to ethtool
Date: Fri, 9 Jan 2009 16:35:20 +1100
Message-ID: <20090109053520.GA13219@gondor.apana.org.au>
References: <20090109041952.GA12087@gondor.apana.org.au> <4966DABD.1000203@pobox.com> <20090109051500.GA12836@gondor.apana.org.au> <4966E0ED.9090905@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhutchings@solarflare.com, rick.jones2@hp.com, davem@davemloft.net,
	netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57213 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752691AbZAIFfi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 00:35:38 -0500
Content-Disposition: inline
In-Reply-To: <4966E0ED.9090905@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2009 at 12:30:21AM -0500, Jeff Garzik wrote:
>
> Actually it's just the opposite -- _the_ most common complaint from  
> users and driver developers of the ethtool interface, over the years,  
> has been that there is no way to collect all the modifications and then  
> commit it to hardware all in one go.

Yes that's a problem for flags that require the drivers to reset
itself.

> Each new ethtool command added often winds up pausing and resetting the  
> hardware completely, and ETHTOOL_SGRO is no exception.

But as I explained before, GRO (like GSO) is purely a software
setting, it has nothing to do with the driver at all.  In other
words we don't need the driver to reset or do anything.

If anything by going into the driver's set_flags function as you
suggested may cause a spurious reset that wouldn't have happened
otherwise.

So for software flags like GSO/GRO at least, I don't see any
benefit in going to a multi-bit interface.  On the flip side,
I see potential complications with a multi-bit interfaces that
simply don't exist with a single-bit interface.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
