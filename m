From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug, kernel panic, NULL dereference , cleanup_once /
 icmp_route_lookup.clone.19.clone / nat , 2.6.39-rc7-git11
Date: Thu, 19 May 2011 07:19:57 +0200
Message-ID: <1305782397.3019.5.camel@edumazet-laptop>
References: <54ec5cd14e5e5c76aa06c2e6899299ce@visp.net.lb>
	 <41a1892fed59b411bb08d3ecb0d8cda5@visp.net.lb>
	 <1305711471.2983.27.camel@edumazet-laptop>
	 <0a630bbf006d1210220a6ba4d55c5804@visp.net.lb>
	 <1305713111.2991.1.camel@edumazet-laptop>
	 <1305719047.2991.4.camel@edumazet-laptop>
	 <4ae96506c000a4b3c8f78ccef836deaf@visp.net.lb>
	 <1305733944.2991.45.camel@edumazet-laptop>
	 <1305746989.3019.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58588 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044Ab1ESFUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 01:20:03 -0400
Received: by wya21 with SMTP id 21so1692531wya.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 22:20:02 -0700 (PDT)
In-Reply-To: <1305746989.3019.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 21:29 +0200, Eric Dumazet a =C3=A9crit :
> Le mercredi 18 mai 2011 =C3=A0 17:52 +0200, Eric Dumazet a =C3=A9crit=
 :
>=20
> > Hmm, it seems we have some inetpeer refcount leak somewhere.
> >=20
> > Maybe one (struct rtable)->peer is not released on dst/rtable remov=
al,
> > or we also leak dst/rtable (and their ->peer inetpeer)
> >=20
> > Watch :
> >=20
> > grep peer /proc/slabinfo
> > grep dst /proc/slabinfo
> >=20
>=20
> FYI, I started a bisection to find the faulty commit.
>=20

Oh well, of course this came to 2c8cec5c10bced240
(ipv4: Cache learned PMTU information in inetpeer.)

So my method to check if we have a leak might be wrong, since the above
commit let cache full of garbage, and hope that following lookups will
find and evict obsolete dst.

Thats getting difficult :(

Could you please send us

grep . /proc/sys/net/ipv4/route/*

Thanks !


