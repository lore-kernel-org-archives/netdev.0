From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug, kernel panic, NULL dereference , cleanup_once /
 icmp_route_lookup.clone.19.clone / nat , 2.6.39-rc7-git11
Date: Wed, 18 May 2011 17:52:24 +0200
Message-ID: <1305733944.2991.45.camel@edumazet-laptop>
References: <54ec5cd14e5e5c76aa06c2e6899299ce@visp.net.lb>
	 <41a1892fed59b411bb08d3ecb0d8cda5@visp.net.lb>
	 <1305711471.2983.27.camel@edumazet-laptop>
	 <0a630bbf006d1210220a6ba4d55c5804@visp.net.lb>
	 <1305713111.2991.1.camel@edumazet-laptop>
	 <1305719047.2991.4.camel@edumazet-laptop>
	 <4ae96506c000a4b3c8f78ccef836deaf@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50790 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756021Ab1ERPw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 11:52:28 -0400
Received: by fxm17 with SMTP id 17so1312074fxm.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 08:52:27 -0700 (PDT)
In-Reply-To: <4ae96506c000a4b3c8f78ccef836deaf@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 15:46 +0300, Denys Fedoryshchenko a =C3=A9=
crit :

>  It is NAS, has ipv6 enabled recently (i am preparing for ipv6), but=20
>  ipv6 is not routed anywhere, maybe just automatically addresses=20
>  appearing on interfaces, including the one looking to customer subne=
t.=20
>  ppp is ipv4 only.
>=20

Hmm, it seems we have some inetpeer refcount leak somewhere.

Maybe one (struct rtable)->peer is not released on dst/rtable removal,
or we also leak dst/rtable (and their ->peer inetpeer)

Watch :

grep peer /proc/slabinfo
grep dst /proc/slabinfo


