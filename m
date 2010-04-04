From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/4] flow: virtualize flow cache entry methods
Date: Sun, 4 Apr 2010 14:19:41 +0800
Message-ID: <20100404061941.GA9642@gondor.apana.org.au>
References: <20100403083609.GA3654@gondor.apana.org.au> <4BB74790.7070109@iki.fi> <20100403141709.GA5165@gondor.apana.org.au> <4BB74FF8.2020303@iki.fi> <20100403155353.GA5618@gondor.apana.org.au> <4BB7A2B8.4040405@iki.fi> <20100404020657.GA8520@gondor.apana.org.au> <4BB828B1.5090109@iki.fi> <20100404055830.GA9484@gondor.apana.org.au> <4BB82C90.70809@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43713 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751140Ab0DDGTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Apr 2010 02:19:44 -0400
Content-Disposition: inline
In-Reply-To: <4BB82C90.70809@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 04, 2010 at 09:07:12AM +0300, Timo Ter=E4s wrote:
>
> With 1/4 only, the bundle deletion is not touched. In that case
> the policy GC deletes explicitly the bundles. The bundles get
> deleted immediately, and only the struct xfrm_policy might get
> held up allocated longer.
>
> The code flow would be:
> 1. xfrm_policy_kill() queues to GC
> 2. xfrm_policy_gc_kill() called from xfrm_policy_gc_task()
>    frees all bundles in that policy
> 3. xfrm_policy_gc_kill() releases it's reference
> 4. ... time passes (flush, randomization, or flow hit occurs)
> 5. flow cache releases it's final reference, calls
>    xfrm_policy_destroy() which only frees the xfrm_policy memory

With 1/4 only, you've removed the flow cache flush when policies
are deleted.  However, you don't add the flow cache flush to the
NETDEV_DOWN case until 2/4.  So with only 1/4, bundles (and hence
netdev objects) may be held for up to 10 minutes.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
