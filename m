From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Mon, 5 Apr 2010 16:49:02 +0800
Message-ID: <20100405084902.GA16912@gondor.apana.org.au>
References: <1270450824-2928-1-git-send-email-timo.teras@iki.fi> <1270450824-2928-2-git-send-email-timo.teras@iki.fi> <20100405083302.GA16636@gondor.apana.org.au> <4BB9A113.30601@iki.fi> <20100405084422.GB16788@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:45070 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750954Ab0DEItG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 04:49:06 -0400
Content-Disposition: inline
In-Reply-To: <20100405084422.GB16788@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 05, 2010 at 04:44:22PM +0800, Herbert Xu wrote:
>
> > It might actually make more sense to pass struct flow_cache_object**
> > so the resolver can twiddle the flow_cache_entry's object. Then it'd
> > be more explicit that the resolver is replacing entries.
> 
> Yes that sounds good.

Alternatively you can pass in a struct flow_cache_entry *.

Yet another way would be to keep it the same but move the NULL
setting before the resolver call:

	flo = NULL;
	if (fle) {
		flo = fle->object;
		fle->object = NULL;
	}
	flo = resolver(..., flo, ...);

This way it's obvious that we've given the reference over to
the resolver.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
