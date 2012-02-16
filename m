From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: limited network bandwidth with 3.2.x kernels
Date: Thu, 16 Feb 2012 16:37:52 +0000
Message-ID: <1329410272.2601.10.camel@bwh-desktop>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <4249109.nLB9JCi9YF@localhost.localdomain>
	 <1329313785.2437.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <2687521.3ztN17SHUf@localhost.localdomain>
	 <1329318481.2437.57.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CADVnQy=UOvC06TBOE7d7WvuKm1Tdkzu7M4dfvm6VRcRJaDMyLw@mail.gmail.com>
	 <1329377352.5646.32.camel@edumazet-laptop>
	 <1329399616.9395.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1329400265.3048.178.camel@deadeye>
	 <1329404975.10004.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neal Cardwell <ncardwell@google.com>,
	Netdev <netdev@vger.kernel.org>, <alekcejk@googlemail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:57212 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751589Ab2BPQiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 11:38:21 -0500
In-Reply-To: <1329404975.10004.3.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-02-16 at 16:09 +0100, Eric Dumazet wrote:
> Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 13:51 +0000, Ben Hutchings a =C3=
=A9crit :
>=20
> > I'm aware of this problem and I believe it exists with most
> > implementations of LRO.
> >=20
> > The out-of-tree version of the sfc driver has its own soft-LRO
> > implementation (SSR) which does some limited connection tracking to
> > detect slow start and disable aggregation temporarily.  I've been
> > meaning to look into enhancing GRO to match SSR, but haven't got ro=
und
> > to it yet.
>=20
>=20
> Not sure why we cant change tcp_grow_window() to take into account
> number of segments in skb ?

Maybe it's as simple as that.  I don't pretend to understand the detail=
s
of TCP flow control.

I checked with David Riddoch who originally implemented SSR.  His
concern was that each aggregated packet received results in at most one
ACK and some senders then won't grow their congestion window as fast as
they would if we were ACKing each wire-level packet (or every 2
packets).  But since current Linux *as a sender* counts the ACKed bytes
and not the packets, I don't think it's relevant to this particular
problem.

Ben.

> It currently increments rcv_ssthresh by a fixed amount (2 * advmss)
>=20
>         if (tcp_win_from_space(skb->truesize) <=3D skb->len)
>                 incr =3D 2 * tp->advmss;
>         else
>                 incr =3D __tcp_grow_window(sk, skb);
>         if (incr) {
>                 tp->rcv_ssthresh =3D min(tp->rcv_ssthresh + incr,
>                                        tp->window_clamp);
>                 inet_csk(sk)->icsk_ack.quick |=3D 1;
>                 }
>=20
>=20
>=20

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
