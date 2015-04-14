From: Ben Hutchings <ben@decadent.org.uk>
Subject: [stable regression] tcp: make connect() mem charging friendly
Date: Tue, 14 Apr 2015 08:32:03 +0100
Message-ID: <1428996723.3211.34.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ykmdmb/iW4HsGThOcCYO"
Cc: Eric Dumazet <edumazet@google.com>, 782515@bugs.debian.org
To: netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:42892 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753822AbbDNIRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 04:17:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ykmdmb/iW4HsGThOcCYO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Commit 355a901e6cf1b2b763ec85caa2a9f04fbcc4ab4a ("tcp: make connect()
mem charging friendly") was backported to various stable branches:

v3.10.73: e64a85197b3f tcp: make connect() mem charging friendly
v3.12.40: d06381e8aac5 tcp: make connect() mem charging friendly
v3.14.37: 5a8e8f482b4a tcp: make connect() mem charging friendly
v3.18.11: e8f117f002ca tcp: make connect() mem charging friendly
v3.13.11-ckt19: de023863df9d tcp: make connect() mem charging friendly
v3.16.7-ckt9: bea5f6ef9fcb tcp: make connect() mem charging friendly

On the 3.16 branch, this has resulted in a regression for TCP Fast Open:
<https://bugs.debian.org/782515>.  The BUG() at the top of
tcp_transmit_skb() fires as tcp_skb_pcount(skb) =3D=3D 0.

tcp_send_syn_data() does:

	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));

Since commit cd7d8498c9a5 ("tcp: change tcp_skb_pcount() location") this
is sufficient to set the GSO segment count correctly.  But in older
branches (< 3.18) the GSO segment count in skb_shared_info is used and
is no longer copied by tcp_send_syn_data().

All the versions listed above, except v3.18.11, appear to have suffered
this regression.

Ben.

--=20
Ben Hutchings
Editing code like this is akin to sticking plasters on the bleeding stump
of a severed limb. - me, 29 June 1999

--=-ykmdmb/iW4HsGThOcCYO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVSzCfee/yOyVhhEJAQqvMQ//bc8BoyU3BkmNCmuk/jQYJ7ExDLe2sESz
zthkkr9TsMPpAHfaGKuaOnqPIDY/jteTLvOoD7Zch9oH5FujrKgyaP+78eYH2CRO
fXnDmMLwg2dcIO8P5AaS1I2d+iQW9dzZMmAuyJV4pZEfgnaKIeeQeR/M+SO3VKNg
+pxPEgnJ379ifmVKssK9cDC1uD+GC8RNTgmri3mImv1bVICIJ2Gx8XD1v66B4anC
acHYNxFTxETn8eM4s+kE7w+H5OplrG1Gg3unDw4TfxVaoiO/WXZNx1wgwSJrejSd
H+QbcCe0HDi7elwVUFeZegswZUnYOcGn1Mkov2Gr8qsTT4o0M4OhFAisGrPqCnGA
uZ0uwNpTET3U+7+Mkc4P5xo94jCe/kHeceTF4rg8ZJpY5e7kE/u8eURSzyK1K7Zf
ok4z9FI3ZQHNVRwphr2hCqaDp3LJUHz/eTnnqO1l3erB9W8SkEDOLMZ2sU1bh8ap
Q55YXT6BWPfS7FnofPqZLB/wWlaon62YVb1QyrsuDbzmitzmcDn3DwEeVekCDL4v
9tnvxCv0PPhHFqXC9MerjgqPPmUcsp9b0R6ZtbvLvSW2IHYrDi8YhmkVdF24j8+j
wUMc7C+8CC6+CWOQgnI0iGcCBzEN4arPPatCmKStsHHz5zszWVvTmC+5djdDL4c7
4C1Qf092/Ks=
=jmx/
-----END PGP SIGNATURE-----

--=-ykmdmb/iW4HsGThOcCYO--
