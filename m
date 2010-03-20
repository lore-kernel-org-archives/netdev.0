From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] xfrm: implement basic garbage collection for bundles
Date: Sat, 20 Mar 2010 21:13:40 +0800
Message-ID: <20100320131340.GB2243@gondor.apana.org.au>
References: <1269087341-7009-1-git-send-email-timo.teras@iki.fi> <20100320123247.GB1930@gondor.apana.org.au> <4BA4C29A.8000806@iki.fi> <20100320124919.GA2243@gondor.apana.org.au> <4BA4C587.60504@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44261 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751718Ab0CTNNp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 09:13:45 -0400
Content-Disposition: inline
In-Reply-To: <4BA4C587.60504@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 20, 2010 at 02:54:31PM +0200, Timo Ter=E4s wrote:
>
> Those are more or less timer based too. I guess it would be
> better to put to dst core's function then. It can see hanging
> refs, and call xfrm gc in that case.

The IPv4 one appears to be invoked from dst_alloc just like
xfrm.

> To even minimize that it would help a lot if xfrm_bundle_ok
> could release (or swap to dummies) the referenced dst->route
> and dst->child entries. xfrm_bundle_ok is mostly called for
> all bundles regularly by xfrm_find_bundle before new ones are
> created.

Yes I agree that's what we should do once your other patch is
applied.

So every top-level xfrm_dst that's not referenced by some user
should sit in the flow cache.  When it's needed and we find it
to be stale we kick it out of the cache and free it along with
the rest of its constituents.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
