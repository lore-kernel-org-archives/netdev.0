From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sat, 3 Apr 2010 16:36:09 +0800
Message-ID: <20100403083609.GA3654@gondor.apana.org.au>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi> <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100403033857.GA2205@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:52836 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752389Ab0DCIgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Apr 2010 04:36:12 -0400
Content-Disposition: inline
In-Reply-To: <20100403033857.GA2205@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 03, 2010 at 11:38:57AM +0800, Herbert Xu wrote:
> 
> With repsect to removing the cache flush upon policy removal,
> what takes care of the timely purging of the corresponding cache
> entries if no new traffic comes through?

In fact this change would seem to render the existing bundle
pruning mechanism when devices are unregistered ineffective.

xfrm_prune_bundles walks through active policy lists to find
the bundles to purge.  However, if a policy has been deleted
while a bundle referencing it is still in the cache, that bundle
will not be pruned.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
