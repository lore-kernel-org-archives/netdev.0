From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 14:03:22 +0800
Message-ID: <20100319060322.GA22319@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi> <20100317145850.GA4257@gondor.apana.org.au> <4BA0FBB6.10208@iki.fi> <4BA27F72.40901@iki.fi> <20100319003130.GA20227@gondor.apana.org.au> <4BA31049.7030005@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:43306 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750865Ab0CSGDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 02:03:25 -0400
Content-Disposition: inline
In-Reply-To: <4BA31049.7030005@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 19, 2010 at 07:48:57AM +0200, Timo Ter=E4s wrote:
>
> But it always matches. The caching happens using the inner
> flow. Inner flow always matches with the same bundle unless
> the bundle expires or goes stale. What happens is that I get
> multiple cache entries per-inner flow each referencing to the
> same bundle.

Sorry for being slow, but if it always matches, doesn't that mean
you'll only have a single bundle in the policy bundle list? IOW
why do we need this at all?

Or have I misread your patch? You *are* proposing to cache the last
used bundle in the policy, right?

> True. But if we go and prune a bundle due to it being bad or
> needing garbage collection we need to invalidate all bundles
> pointers, and we cannot access the back-pointer. Alternatively

Why can't you access the back-pointer? You should always have
a reference held on the policy, either explicit or implicit.

> we need to keep xfrm_dst references again in the flow cache
> requiring an expensive iteration of all flow cache entries
> whenever a xfrm_dst needs to be deleted (which happens often).

So does the IPv4 routing cache.  I think what this reflects is
just that the IPsec garbage collection mechanism is broken.

There is no point in doing a GC on every dst_alloc if we know
that it isn't going to go below the threshold.  It should gain
a minimum GC interval like IPv4.  Or perhaps we can move the
minimum GC interval check into the dst core.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
