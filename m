From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 20:14:15 +0800
Message-ID: <20080923121414.GB29257@gondor.apana.org.au>
References: <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi> <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi> <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi> <20080923064707.GA26836@gondor.apana.org.au> <48D8B967.8000107@iki.fi> <20080923112416.GA28946@gondor.apana.org.au> <48D8DC28.1020001@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33534 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750950AbYIWMOV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 08:14:21 -0400
Content-Disposition: inline
In-Reply-To: <48D8DC28.1020001@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 03:08:08PM +0300, Timo Ter=E4s wrote:
>
> +		list_for_each_entry(walk, &xfrm_state_walks, list) {
> +			if (walk->state =3D=3D x)
> +				walk->state =3D next;
> +		}

Just make a new list in xfrm_state that has all the dumpers sitting
on it.  In fact all you need is a hlist, or even just a pointer.

Walking through an unbounded list on the fast path is not good :)

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
