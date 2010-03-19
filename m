From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: cache bundle lookup results in flow cache
Date: Fri, 19 Mar 2010 08:31:30 +0800
Message-ID: <20100319003130.GA20227@gondor.apana.org.au>
References: <1268655610-7845-1-git-send-email-timo.teras@iki.fi> <20100317130704.GA2601@gondor.apana.org.au> <4BA0E435.6090801@iki.fi> <20100317145850.GA4257@gondor.apana.org.au> <4BA0FBB6.10208@iki.fi> <4BA27F72.40901@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54580 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751228Ab0CSAbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Mar 2010 20:31:34 -0400
Content-Disposition: inline
In-Reply-To: <4BA27F72.40901@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 18, 2010 at 09:30:58PM +0200, Timo Ter=E4s wrote:
>
> Now, these created xfrm_dst gets cached in policy->bundles
> with ref count zero and not deleted until garbage collection
> is required. That's how xfrm_find_bundle tries to reuse them
> (but it does O(n) lookup).

Yes but the way you're caching it in the policy means that it
only helps if two consecutive packets happen to match the same
bundle.  If your traffic mix was such that each packet required
a different bundle, then we're back to where we started.

That's why I was asking for you to directly cache the xfrm_dst
objects in the flow cache.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
