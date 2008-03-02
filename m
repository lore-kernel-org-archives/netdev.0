From: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
Subject: Re: [PATCH 2/2] [IPV6]: Fix source address selection for ORCHID
	addresses
Date: Sun, 2 Mar 2008 18:54:53 +0200
Message-ID: <20080302165453.GP32279@verkkotelakka.net>
References: <20080221100842.GA24905@verkkotelakka.net> <20080302.213902.68664760.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="1y1tiN5hVw5cPBDe"
Cc: netdev@vger.kernel.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from refraktori.verkkotelakka.net ([79.171.233.68]:32831 "EHLO
	refraktori.verkkotelakka.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753456AbYCBQy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 11:54:56 -0500
Content-Disposition: inline
In-Reply-To: <20080302.213902.68664760.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--1y1tiN5hVw5cPBDe
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Mar 02, 2008 at 09:39:02PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ w=
rote:
> In article <20080221100842.GA24905@verkkotelakka.net> (at Thu, 21 Feb 200=
8 12:08:42 +0200), Juha-Matti Tapio <jmtapio@verkkotelakka.net> says:
> > Skip the prefix length matching in source address selection for
> > orchid -> non-orchid addresses.
> >=20
> > Overlay Routable Cryptographic Hash IDentifiers (RFC 4843,
> > 2001:10::/28) are currenty not globally reachable. Without this
> > check a host with an ORCHID address can end up preferring those over
> > regular addresses when talking to other regular hosts in the 2001::/16
> > range thus breaking non-orchid connections.
> >=20
> > Signed-off-by: Juha-Matti Tapio <jmtapio@verkkotelakka.net>
>=20
> Is this really required?
> I believe address labels (rule 6) should work, no?

The corner case that I run into was like this (using HIPL):

$ ip -6 addr
1: lo: <LOOPBACK,UP,10000> mtu 16436
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qlen 1000
    inet6 2002:4fab:e944:1100::1/64 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::2c0:4fff:fe17:ecd9/64 scope link
       valid_lft forever preferred_lft forever
3: tun0: <POINTOPOINT,MULTICAST,NOARP,UP,10000> mtu 1500 qlen 100
    inet6 fe80::2/64 scope link
       valid_lft forever preferred_lft forever
8: dummy0: <BROADCAST,NOARP,UP,10000> mtu 1500
    inet6 2001:1c:ed0f:6dda:e9c3:8921:2ee7:7a52/28 scope global
       valid_lft forever preferred_lft forever
[...]

$ ip -6 route
2001:1c:ed0f:6dda:e9c3:8921:2ee7:7a52 dev dummy0  metric 1024  expires 8567=
991sec mtu 1500 advmss 1440 hoplimit 4294967295
[...]
2002:4fab:e944:1100::/64 dev eth0  metric 256  expires 8211503sec mtu 1500 =
advmss 1440 hoplimit 4294967295
[...]
default via fe80::1 dev tun0  metric 512  expires 8211512sec mtu 1500 advms=
s 1440 hoplimit 4294967295
[...]

In this case if I try to connect to www.ripe.net alias
2001:610:240:11::c100:1319, there is no local source address that
matches the destination's label and the outgoing interface does not
have any public addresses. Therefore the 8th rule applies and the HIT
(2001:...) wins and the destination can not understand the source
address.

I'm not particularly happy with the above mentioned second patch, but
I could not come up with a more elegant fix.


--=20
Tmi Juha-Matti Tapio    Puh/Tel. +358-50-5419230
Y-tunnus 1911527-0      Fax      +358-9-34756631

--1y1tiN5hVw5cPBDe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFHytvdRGhQc/k/gTsRAvVqAJwJyygi6FR192fAzjqyAtupqjqkcACgl2Yf
42NautugYD3aThxAGnuY4E0=
=d7UG
-----END PGP SIGNATURE-----

--1y1tiN5hVw5cPBDe--
