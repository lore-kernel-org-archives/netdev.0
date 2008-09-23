From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 12:59:51 +0800
Message-ID: <20080923045951.GA26048@gondor.apana.org.au>
References: <20080902.234723.163403187.davem@davemloft.net> <20080905115506.GA26179@gondor.apana.org.au> <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi> <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi> <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:50165 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751051AbYIWE75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 00:59:57 -0400
Content-Disposition: inline
In-Reply-To: <48D8763E.4030607@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 07:53:18AM +0300, Timo Ter=E4s wrote:
>
> So the idea was to hold X->next from deletion function, not from
> the walking function. That would be, we always hold deleted->next whe=
n
> there are ongoing walks. And on final _put() we _put() the ->next
> entry.
>=20
> I think that would work.

Right, this would work.

However, now you're again slowing down the relatively fast path of
state deletion by moving extra work there from the non-critical
dump path.

When we optimise code for time, we don't necessarily try to minimise
the work overall.  We instead try to minimise the amount of work on
the critical paths.  It's OK to let the other paths such as dumping
do a bit more work if it improves the fast paths.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
