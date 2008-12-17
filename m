From: Petr Tesarik <ptesarik@suse.cz>
Subject: Re: [PATCH] tcp: make urg+gso work for real this time
Date: Wed, 17 Dec 2008 11:45:13 +0100
Message-ID: <1229510713.13305.17.camel@nathan.suse.cz>
References: <E1LCtSp-0004Rc-Lb@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, davem@davemloft.net,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:45901 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754195AbYLQKpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2008 05:45:14 -0500
In-Reply-To: <E1LCtSp-0004Rc-Lb@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu p=C3=AD=C5=A1e v St 17. 12. 2008 v 21:17 +1100:
> Petr Tesarik <ptesarik@suse.cz> wrote:
> >=20
> >  1. Currently this code path will never get run, because large
> >     offloads are avoided both for hardware TSO and software GSO.
> >     You'd also have to modify the conditionals that guard calls
> >     to tcp_mss_split_point().
>=20
> Obviously one would revert the existing fixes after this is applied.
>=20
> >  2. Is it worth the trouble?
> >     This slows down the software GSO slightly. I mean, urgent
> >     data should be quite rare, so it makes sense to treat
> >     non-urgent data as "fast path" and urgent data as "slow
> >     path". While Ilpo's approach only slows down the slow path,
> >     your patch slows down both.
>=20
> Well it might slow down the GSO path slightly, but it speeds
> up the TSO generation path accordingly :) I think the cost is
> negligible in either case so the benefit of TSO dominates.

You're talking about the urgent-data case, right? Yes, for urgent data,
correctly implemented GSO will no doubt be faster than splitting the
skb. But GSO will also get (a bit) slower for the non-urgent-data case,
where the slowdown is not compensated by anything. Or did I miss
something obvious?

Petr Tesarik
=20
> > Anyway, we have to keep the code that avoids large offloads with UR=
G,
> > because many NICs are broken in this regard (at least all Intel NIC=
s
> > I've seen so far), so why treat software GSO specially?
>=20
> That's not a problem.  Unless the NIC sets NETIF_F_TSO_URG (which
> nobody does currently because it's a new flag), we'll do the
> segmentation in software, but only if the packet is marked as URG.
>=20
> This is identical to how we handle ECN which most NICs get wrong
> as well.
>=20
> Cheers,

