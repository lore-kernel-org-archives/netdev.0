From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 4 Apr 2010 13:58:30 +0800
Message-ID: <20100404055830.GA9484@gondor.apana.org.au>
References: <1270126340-30181-2-git-send-email-timo.teras@iki.fi> <20100403033857.GA2205@gondor.apana.org.au> <20100403083609.GA3654@gondor.apana.org.au> <4BB74790.7070109@iki.fi> <20100403141709.GA5165@gondor.apana.org.au> <4BB74FF8.2020303@iki.fi> <20100403155353.GA5618@gondor.apana.org.au> <4BB7A2B8.4040405@iki.fi> <20100404020657.GA8520@gondor.apana.org.au> <4BB828B1.5090109@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:60113 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751140Ab0DDF6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 01:58:33 -0400
Content-Disposition: inline
In-Reply-To: <4BB828B1.5090109@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 04, 2010 at 08:50:41AM +0300, Timo Ter=E4s wrote:
>
> For the common case:
>
> 1. Policy deleted; policy->walk.dead set, policy->genid incremented
> 2. NETDEV_DOWN hook called, calls flow_cache_flush()
> 3. flow_cache_flush enumerates all policy and bundle refs
>   in it's cache
> 4. for each bundle xfrm_bundle_check_fce() is called, which
>   calls stale_bundle()
> 5. all bundles using stale policy, fail that check because
>     xdst->policy_genid !=3D xdst->pols[0]->genid
>   (checked in xfrm_bundle_ok)
> 6. flow cache calls entry's ->delete which is dst_free for bundles
> 7. flow_cache_flush() returns

Ah, you're doing it in 2/4.  Can we please have each patch be
a self-contained unit? It should be possible to apply 1/4 and
have a resulting kernel that works properly without having to
apply the rest of your patches.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
