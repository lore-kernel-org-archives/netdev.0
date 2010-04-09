From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Crashes in xfrm_lookup
Date: Fri, 9 Apr 2010 17:25:17 +0800
Message-ID: <20100409092517.GA2645@gondor.apana.org.au>
References: <20100409080907.GA2029@gondor.apana.org.au> <4BBEE144.8070600@iki.fi> <20100409082239.GA2194@gondor.apana.org.au> <4BBEE5B9.2060509@iki.fi> <20100409083934.GA2353@gondor.apana.org.au> <4BBEE990.6080807@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: broonie@opensource.wolfsonmicro.com, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:56332 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754567Ab0DIJZZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Apr 2010 05:25:25 -0400
Content-Disposition: inline
In-Reply-To: <4BBEE990.6080807@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 09, 2010 at 11:47:12AM +0300, Timo Ter=E4s wrote:
>
> No. Prior it had one element unconditionally. My patch made
> it have zero or one element. The non-SUB_POLICY case crashed
> because xfrm_pols_put(xxx, 0) unconditionally calls
> xfrm_policy_put on unused pointer.

OK I was mistaken.

> __xfrm_lookup(). In the end it uses: "xfrm_pols_put(pols, drop_pols)"
> to free up policies that are looked up with xfrm_sk_policy_lookup().
> The only major code path there is, if per-socket policy has no
> transformations (which is common case, ike daemons do this so they
> can talk IKE without transformations).
>
> If we have cached bundle, the policies are referenced to from the
> bundle and we do not need to reference, or release them in the
> lookup function.
>
> It is a bit icky. But it's the only way to do it, since no one
> wanted to cache per-socket bundles in the flow cache.

BTW, socket policies cannot be sub-policies so you don't need
to expand policies for them.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
