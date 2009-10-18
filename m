From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][RFC]: ingress socket filter by mark
Date: Sun, 18 Oct 2009 19:28:35 +0200
Message-ID: <4ADB5043.7070707@gmail.com>
References: <1255869758.4815.40.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Atis Elsts <atis@mikrotik.com>,
	=?windows-1252?Q?Maciej_Z=2Eenczykowski?= <zenczykowski@gmail.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38947 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879AbZJRRaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 13:30:30 -0400
In-Reply-To: <1255869758.4815.40.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal a =E9crit :
> Maciej forced me to dig into this ;->
>=20
> at the socket level if a packet arrives with a different mark than
> what we bind to, drop it. I have tested this patch and it drops a pac=
ket
> with mismatching mark.
>=20
> There are several approaches - and i think the patch suggestion i hav=
e
> made here maybe too strict. I assume that if someone binds to a mark,
> they want to not only send packets with that mark but receive
> only if that mark is set.=20
> A looser check would be something along the line accept as well if ma=
rk
> is not set i.e
> if (sk->sk_mark && skb->mark && sk->sk_mark !=3D skb->mark)
>=20
> Alternatively i could add one bit in the socket flags and have it so
> that check is made only if app has been explicit:
> if (sock_flag(sk, SOCK_CHK_SOMARK) && sk->sk_mark !=3D skb->mark) dro=
p
>=20
> Another approach  is to set sock filter from app. I dont like this
> approach because it will be the least usable from app level and would=
 be
> the least simple from kernel level.
>=20
> cheers,
> jamal
>=20

I vote for extending BPF, and not adding the price of a compare
for each packet. Only users wanting mark filtering should pay the price=
=2E

