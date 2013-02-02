From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Sat, 2 Feb 2013 14:22:53 +1100
Message-ID: <20130202142253.e31167bf695f000c0c78f4cc@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Sat__2_Feb_2013_14_22_53_+1100_iAj=Jt9rSdQWnb0v"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Jiri Pirko <jiri@resnulli.us>,
	=?UTF-8?B?IllPU0hJRlVKSSBIaWRlYWtpIC8g5ZCJ6Jek6Iux5piOIg==?=
	<yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from haggis.pcug.org.au ([203.10.76.10]:39833 "EHLO
	members.tip.net.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757590Ab3BBDW4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 22:22:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Sat__2_Feb_2013_14_22_53_+1100_iAj=Jt9rSdQWnb0v
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/ipv6/route.c between commit bd30e947207e ("ipv6: do not create
neighbor entries for local delivery") from the net tree and commit
c440f1609b65 ("ipv6: Do not depend on rt->n in ip6_pol_route()") from the
net-next tree.

I fixed it up (I think - see below) and can carry the fix as necessary
(no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/ipv6/route.c
index 363d8b7,f3328bc..0000000
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@@ -928,7 -884,7 +884,7 @@@ restart
  	dst_hold(&rt->dst);
  	read_unlock_bh(&table->tb6_lock);
 =20
- 	if (!rt->n && !(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_LOCAL)))
 -	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_GATEWAY)))
++	if (!(rt->rt6i_flags & (RTF_NONEXTHOP | RTF_LOCAL | RTF_GATEWAY)))
  		nrt =3D rt6_alloc_cow(rt, &fl6->daddr, &fl6->saddr);
  	else if (!(rt->dst.flags & DST_HOST))
  		nrt =3D rt6_alloc_clone(rt, &fl6->daddr);

--Signature=_Sat__2_Feb_2013_14_22_53_+1100_iAj=Jt9rSdQWnb0v
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJRDIaNAAoJEECxmPOUX5FEkQkP/igox+vuoIvcKiwo9HyG7XJU
Vbeh1nVIrJmtOBREE3Ngnj/dXa/Dhvyi/rY5DQdJ11uGOPyWRCf3oWrrlZNl3JLH
BvURxweh+bbHqRnOzpZvUwXjBYk3mB7/ycnj01Riywe4yR5tq4SH3pFRebctjMt2
WDVg/eW8PDYlotvHwphaCvnjpnmIs225/YWXbUNO5Un4epjeYnxnRA2if2627VTB
ugSQEzoFv3HNklN5ZP5xCgQKqlAxbAoE9iw8BwEoc5BWzsVqFWFkkeVw6NSP3e/x
GlQLgdcOo2BC/Mg24f25HoGfebRKF+oqfFt3RynvcOJKOFCelAKjezOYKWBqoydl
BaoAaXlhY7vnL746b+kk7jguEnwpbBsEvfIhn4W4PHV8X282PtqWJ1GHfhH/x/XR
HszfIIJjybT+x2Tg8dn7Y99lgzlais9eXc6llYoiq11fwYBApKj9rzgnUakRPJOP
SowNfYGTznbDhQN5TksH0N8xMv2rSGg2z1FG7r2/O4yBcgjr+cIs5pzTkOmAsHec
44BgvkyMsRYLRWWDPguyyVCp/hqnozjN9e7p4lQPS/JXMBrI17b2nwtUQc8I1LXE
57io3S7yvM6rpSJKw8PNfBqH7yd0xX8YMv5wtCLuRzCcN9uXFIEFejOiT8ZS2RzW
WnYdi9lIY/61FLmYyuxo
=g7Qb
-----END PGP SIGNATURE-----

--Signature=_Sat__2_Feb_2013_14_22_53_+1100_iAj=Jt9rSdQWnb0v--
