From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: sparse vs. skbuff.h
Date: Mon, 16 Nov 2009 20:27:07 +0100
Message-ID: <1258399627.32159.41.camel@johannes.local>
References: <1258399271.32159.39.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-+UNVwAzErLEyezYferqc"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Vegard Nossum <vegard.nossum@gmail.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:34424 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751777AbZKPT1C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 14:27:02 -0500
In-Reply-To: <1258399271.32159.39.camel@johannes.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+UNVwAzErLEyezYferqc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-11-16 at 20:21 +0100, Johannes Berg wrote:
> commit 14d18a81b5171d4433e41129619c75748b4f4d26
> Author: Eric Dumazet <eric.dumazet@gmail.com>
> Date:   Thu Oct 29 00:10:37 2009 +0000
>=20
>     net: fix kmemcheck annotations
>=20
>=20
> broke sparse endian checks on everything that includes skbuff.h because
> the first and only (because it's an error) thing sparse now reports is
> this:
>=20
> include/linux/skbuff.h:357:41: error: invalid bitfield specifier for type=
 restricted __be16.

Simply changing from
	__be16 protocol:16;
to
	__be16 protocol;

but leaving it inside the kmemcheck annotation seems to do the right
thing. Except of course that kmemcheck will not properly check it now.
Maybe those annotations should simply be made to have no impact on
struct padding instead?

johannes

--=-+UNVwAzErLEyezYferqc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJLAaeIAAoJEODzc/N7+QmaOToQAJssJqFKdIhNxC80+voAaOow
4HtItwFXovwow1opbJ3cr/Pl10mc5pgI2Q8d/WhtNrb5r1+y2g4fXHlL/Kw8MSGD
4AvesOkKDWuFSIwZRSTjrVxDwUt8BIbAxo7AIGF6Jrkum0oiVJG7Yoi5WMt9mw0E
5QEtEUf9vDFeTO7dvh4pHiclZOIAHvCa5xMn20TyB0Ei9Ef6bvHlrxHBIKwGqe7f
0fJxkRFcVGwKRX/m4Zg7Ge05/mteD7orrc6TeAkhNbu70jFnhZXvc+8W00m4DQi/
QKEHzzaZZVm8+rl/AIcm18CO7BRcqhOeIbsVUtoSOBcAMhdj4TQrA1GjWOw4TR99
Ok/BU0zCJw89diOzN8UEzMN51Hrk39VHt9nAf+6JW4y2mbvmp5TvYtsV9AhgjOBD
h0OAgZudjQEkJ0sy+44/pkSGaawtOQnsluE40cJdd9lnA1HmldeSMrHkAJPD8J0T
A1PRdtX2QhQN2tuyZUKRFMszj+al4LcEDu5fhPNaasC1aTE1yUI/lbLCwSkJwlpl
IpVgK499zVIOWYuoOqGnPqbOfwkTG0A1MyAgyHPKCsBaaMwHG3xiqYGSFbuzS7Hr
z9NnKfx9WDc6oiq0/U5ZKiOaUeSh301VSOY1tXYjZRTeL8tn9OkUcx7UnCq+raxQ
tIpAsg7SCvw7kikp6rOz
=huv5
-----END PGP SIGNATURE-----

--=-+UNVwAzErLEyezYferqc--

