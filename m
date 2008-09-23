From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm_state locking regression...
Date: Tue, 23 Sep 2008 15:25:41 +0300
Message-ID: <48D8E045.8040508@iki.fi>
References: <20080922235012.GA23658@gondor.apana.org.au> <48D8763E.4030607@iki.fi> <20080923045951.GA26048@gondor.apana.org.au> <48D87BDA.8040804@iki.fi> <20080923052239.GA26233@gondor.apana.org.au> <48D88BCC.5030806@iki.fi> <20080923064707.GA26836@gondor.apana.org.au> <48D8B967.8000107@iki.fi> <20080923112416.GA28946@gondor.apana.org.au> <48D8DC28.1020001@iki.fi> <20080923121414.GB29257@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.186]:33393 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbYIWMZs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2008 08:25:48 -0400
Received: by fk-out-0910.google.com with SMTP id 18so2056594fkq.5
        for <netdev@vger.kernel.org>; Tue, 23 Sep 2008 05:25:46 -0700 (PDT)
In-Reply-To: <20080923121414.GB29257@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Tue, Sep 23, 2008 at 03:08:08PM +0300, Timo Ter=E4s wrote:
>> +		list_for_each_entry(walk, &xfrm_state_walks, list) {
>> +			if (walk->state =3D=3D x)
>> +				walk->state =3D next;
>> +		}
>=20
> Just make a new list in xfrm_state that has all the dumpers sitting
> on it.  In fact all you need is a hlist, or even just a pointer.

There can be a lot of xfrm_state structs. As in thousands. So it
will take more memory then. hlist would be enough, so it'd be a
4/8 bytes addition. Single pointer would not be enough as we can
have multiple walks on the same entry.

> Walking through an unbounded list on the fast path is not good :)

I was thinking about the same. That's why I wasn't so sure if this is
better. In practice there aren't many walks active. Maybe we limit
the maximum simultaneous walks?

But in real life, there is only a one or two walkers if any active.
So I would not consider a global update too expensive. But if you think
it might become a problem, I'd add an hlist to xfrm_state of walkers
referencing that entry.

- Timo
