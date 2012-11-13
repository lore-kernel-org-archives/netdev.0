From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCHES] Networking fixes for -stable.
Date: Tue, 13 Nov 2012 19:51:26 +0000
Message-ID: <1352836286.16264.102.camel@deadeye.wl.decadent.org.uk>
References: <20121112.002558.46179003870204789.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-55Di2aD6N51zXXa0t3vN"
Cc: stable@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50928 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754329Ab2KMTvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 14:51:39 -0500
In-Reply-To: <20121112.002558.46179003870204789.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-55Di2aD6N51zXXa0t3vN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-11-12 at 00:25 -0500, David Miller wrote:
> Please queue up the following networking bug fixes for
> 3.0.x, 3.2.x, 3.4.x, and 3.6.x, respectively.
[...]
> From 2204849a85383fbde75680aa199142abe504adbb Mon Sep 17 00:00:00 2001
> From: Peter Senna Tschudin <peter.senna@gmail.com>
> Date: Sun, 28 Oct 2012 06:12:01 +0000
> Subject: [PATCH 7/9] drivers/net/phy/mdio-bitbang.c: Call mdiobus_unregis=
ter
>  before mdiobus_free
>=20
> [ Upstream commit aa731872f7d33dcb8b54dad0cfb82d4e4d195d7e ]
>=20
> Based on commit b27393aecf66199f5ddad37c302d3e0cfadbe6c0
>=20
> Calling mdiobus_free without calling mdiobus_unregister causes
> BUG_ON(). This patch fixes the issue.
[...]

This introduces a regresssion, as mdiobus_unregister() is not safe to
call if the bus isn't registered.  Registration is controlled by the
drivers that use mdio-bitbang, and they should take care of
unregistration too - and most of them do.

This should be reverted in mainline and not applied to any stable
series.

Ben.

--=20
Ben Hutchings
For every complex problem
there is a solution that is simple, neat, and wrong.

--=-55Di2aD6N51zXXa0t3vN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUKKkvue/yOyVhhEJAQoBEQ//QjYfIs8pIl3tP4Grmp3wjBIknU4p6ELY
LB/up9cP9DJNqRZIzqmcnx+4+zEDgElvL/sJ4w/ywUKY31iuDpDbZFq77XhqsB2v
fWIpvQzirqIpflKujuS8cPwfvXlF2LpZfwMy0J0UGYf/zjxTJijIqjgBPNx8+M4M
a9nmb/rSvPvm8UTfIcVmMFe7DCtEUF1HdZQ57uOhw7d3Y78ivqqz+EfA4IQ6ihpq
81u/lhblQaVKZUhIeCKaIYtH73OClzhkRgPmFhHwBSnfMibLDUA0lKJH2KkDrKS6
KSEDoqglYnURSO0CT1ud0yylVMikEPreS1LQ1xa3ybF2ZxIDKy1UZv+QspnCBF4f
Jt0F4TUGoQJ0de24mmRMWZmT5sf5wP4FAyL2GZpbU6VT7jFDUVVI1ZVj302/01C8
4ohb+ebWmJoPwMrTh0ubH2KjtzU1FEEvQ2cr3iRrgoiEC9Qo/uzu+j2QWxFHBdgf
ShmmPLzQB1PlVCptiSXg/EUX0jA/JbzNzgiZstHfuKB9Ox7hMm/pzm0L/lud/K2u
7CwC6e3ssoeKTaVN+nockhWkjKk7Qdnh8yJlUDnAkRgB1Rv+3VSrEn1CkPCgIDTG
xZqzm619o8iBxj4ndIRF+DY4AYcuv1lc5c0yIKkButeSgDK5ph1U51NFOB+Jd3PM
iYcuHRjH9Fw=
=Vs7R
-----END PGP SIGNATURE-----

--=-55Di2aD6N51zXXa0t3vN--
