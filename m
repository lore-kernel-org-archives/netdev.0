From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Sun, 21 Mar 2010 08:46:59 +0800
Message-ID: <20100321004659.GA5895@gondor.apana.org.au>
References: <20100319072053.GA22913@gondor.apana.org.au> <4BA32C41.2020000@iki.fi> <20100319082909.GA23363@gondor.apana.org.au> <4BA337E6.4010508@iki.fi> <20100319084717.GA23567@gondor.apana.org.au> <4BA33FF5.8010104@iki.fi> <20100319093210.GA23895@gondor.apana.org.au> <4BA349A8.9050105@iki.fi> <20100320151751.GB2950@gondor.apana.org.au> <4BA4F718.3020700@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60170 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753076Ab0CUArF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 20:47:05 -0400
Content-Disposition: inline
In-Reply-To: <4BA4F718.3020700@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 20, 2010 at 06:26:00PM +0200, Timo Ter=E4s wrote:
>
> So should go ahead and:
> 1. modify flow cache to be more generic (have virtual put and get
>   for each object; and remove the atomic_t pointer)
> 2. modify flow cache to have slow and fast resolvers so we can
>   copy with the current sleeping requirement

I don't think we need either of these.  To support the sleep
requirement, just return -EAGAIN from the resolver when the
template can't be resolved.  Then the caller of flow_cache_lookup
can sleep as it does now.  It simply has to repeat the flow
cache lookup afterwards.

> 3. cache bundles instead of policies for outgoing stuff
> 4. kill find_bundle and just instantiate new ones if we get cache
>   miss
> 5. put all bundles to global hlist (since only place that walks
>   through them is gc, and stale bundle can be dst_free'd right
>   away); use genid's for policy to flush old bundles
> 6. dst_free and unlink bundle immediately if it's found to be stale

Sounds good.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
