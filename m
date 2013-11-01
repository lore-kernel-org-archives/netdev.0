From: Emmanuel Thierry <emmanuel.thierry@telecom-bretagne.eu>
Subject: Re: [RFC PATCH 1/2] ipv6: select oif corresponding to source address
Date: Fri, 1 Nov 2013 18:34:32 +0100
Message-ID: <1BD1928C-A847-4C74-AF7E-5B955768B12B@telecom-bretagne.eu>
References: <06F9072B-27A3-4A21-ADE2-A5B3FE817A1F@telecom-bretagne.eu>
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zproxy210.enst-bretagne.fr ([192.108.117.8]:49534 "EHLO
	zproxy210.enst-bretagne.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752662Ab3KARec convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 13:34:32 -0400
In-Reply-To: <06F9072B-27A3-4A21-ADE2-A5B3FE817A1F@telecom-bretagne.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

These two rfc patches fix problems stated in "ipv6: strange routing beh=
aviors on a multi-interfaces setup" on 2013-09-25:

>=20
> I'm working on multi-interfaces setups on IPv6. I found several distu=
rbing route behaviors which sounds like bugs to me.
>=20
> Both eth1 and eth2 interfaces receive RAs from distinct routers and a=
utoconfigure:
> * their slaac address
> * their default route, both with the same priority
> Under these conditions, the following happen depending on the expirat=
ion time of each route.
>=20
>=20
> 1/ A ping with a specified source address and interface may go throug=
h the wrong interface.
>=20
> # ping6  -c 1 -I "<slaac_eth1>%eth1" <dest>
> =85 uses the right interface (eth1) with the right source address (<s=
laac_eth1>).
>=20
> # ping6  -c 1 -I "<slaac_eth2>%eth2" <dest>
> =85 uses the wrong interface (eth1) with the right source address (<s=
laac_eth2>).
>=20
> The ping6 utility performed a bind() on <slaac_ethx> with scope id se=
t to <ifindex_ethx>.
> If we flush the routing cache between each ping, the routing is done =
as expected.
>=20
> As i could observe in the kernel. When ip6_pol_route() is called, oif=
 is equal to <ifindex_eth2> but the flag RT6_LOOKUP_F_IFACE is not set.=
 This makes routes through other interfaces to still be valid.
> Shouldn't we set the RT6_LOOKUP_F_IFACE flag when a scope id is speci=
fied ?
>=20
>=20
> 2/ A ping from a specified source address may go through the wrong in=
terface.
>=20
> # ping6  -I "<slaac_eth2>" <dest>
> =85 may use eth1 with <slaac_eth2>.
>=20
> The ping6 utility performed a bind() on <slaac_eth2>
> This is a derivative from the first one, with the significative diffe=
rence that it also happens if the routing cache is empty. The most rece=
nt default route is chosen regardless of the source address.
>=20
> Shouldn't we look in a first try for routes on the device correspondi=
ng to the source address, and in a second try for others ?
>=20
>=20
> 3/ A ping from a specified interface may go through the wrong interfa=
ce with the wrong source address.
>=20
> # ping6  -I "eth2" <dest>
> =85 may use eth1 with <slaac_eth1>.
>=20
> The ping6 performs a setsockopt(IPV6_PKTINFO) with <ifindex_ethx>, th=
en a connect() to the destination. In this case, source address selecti=
on is concerned, but also routing since source address selection depend=
s on routing.
>=20
>=20
> I experienced these problems on a 3.11.1 kernel but they look to be q=
uite recurrent in the past versions as well.=20
>=20

Best regards
Emmanuel Thierry
