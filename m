From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 13:22:39 +0800
Message-ID: <20080923052239.GA26233@gondor.apana.org.au>
References: <20080908.172513.162820960.davem@davemloft.net> <20080909143312.GA29952@gondor.apana.org.au> <48D63E3A.90301@iki.fi> <48D66677.2040309@iki.fi> <20080922114256.GA27055@gondor.apana.org.au> <48D7971A.5050107@iki.fi> <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi> <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:42465 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751524AbYIWFWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 01:22:48 -0400
Content-Disposition: inline
In-Reply-To: <48D87BDA.8040804@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 23, 2008 at 08:17:14AM +0300, Timo Ter=E4s wrote:
>
> The extra step there wold be a hold call. The recursive _put on a
> _put of some entry can happen only on dump path. As otherwise the
> ->next entry is first held in state delete, but would be immediately
> _put on the _put as the final step of _delete().
>=20
> So basically one additional atomic_inc() and one atomic_dec() on the
> normal _delete() path.

Can you post a patch? If this can be done locklessly then yes
it would probably be a good way to go.  However, I'm not sure
whether I understand your lockless proposal yet.

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
