From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 23:20:54 +0000
Message-ID: <1269732054.8653.155.camel@localhost>
References: <4BADDDB7.4010005@iki.fi>
	 <20100327114059.GA3432@electric-eye.fr.zoreil.com>
	 <4BADF01E.9090906@iki.fi>
	 <20100327120358.GA5114@electric-eye.fr.zoreil.com>
	 <4BADF738.2060600@iki.fi>
	 <20100327122642.GA5165@electric-eye.fr.zoreil.com>
	 <4BADFAE4.5040906@iki.fi> <4BAE6C92.2060801@iki.fi>
	 <20100327211133.GA3624@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-iz5Zwfz92bkXRLotlOXF"
Cc: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40006 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754049Ab0C0XVG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 19:21:06 -0400
In-Reply-To: <20100327211133.GA3624@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-iz5Zwfz92bkXRLotlOXF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sat, 2010-03-27 at 22:11 +0100, Fran=C3=A7ois Romieu wrote:
> Timo Ter=C3=A4s <timo.teras@iki.fi> :
> [...]
> > Any ideas how to check this?
>=20
> Check the datasheet of VIA's chipset for a WC control bit - there
> ought to be one - and disable it.
>=20
> > Or is swapping MAC0/MAC4 writes, or adding the extra read an
> > acceptable fix/workaround?
>=20
> swapping should reliably disable WC. It would be fine.

This bug was also reported by a Debian user in
<http://bugs.debian.org/573007>, also using a VIA chipset.

This sort of behaviour has been seen before with 64-bit registers
written in two 32-bit chunks, on some ARM platforms.  You worked around
that for the descriptor pointers with:

ommit b39fe41f481d20c201012e4483e76c203802dda7
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Mon Sep 11 20:10:58 2006 +0200

    r8169: quirk for the 8110sb on arm platform

A similar problem seems to afflict the multicast hash register on this
platform - see <http://bugs.debian.org/407217>, and sorry I didn't
report this earlier when I got confirmation of my hypothesis.

I wonder whether there are special rules that need to be followed for
updating such registers and which the driver is not following, or a more
general bug in the Realtek chips that should be consistently
worked-around for all 64-bit registers.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-iz5Zwfz92bkXRLotlOXF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUAS66S0ee/yOyVhhEJAQJb5RAAqO/byUwg28MrJPuMKKCclWhM5We8vPTO
aCJx2RiB2vqkO1beCEVP4EHnasLoXNZ7PkM6XLHTobKF6fLn4ryTRLQseMWC7nT5
deEuSpMqSU9uaf3ymysFUM0+0Jns+jnQlu4ykVyzZI8O+TRmWTkdGvGtegPUUBMV
pam5TNSI570vFS35NNcQCKJ6jMHjf2YWxGnniIYsoV0I68RG6CwKtXI46uvnx0Sa
H7Yvv98tJ1CXKNFm7fDZDjuWvQl2iVHA47pjoA9QibZlvJJUdDZKhRacJgIBunID
6nkm4R2kupx8oSkO2k9G7YDKphZGTAkzvjkaAbJFqgGGy5Dcq9Uz3OGQo/ZShWCD
AHyTA0DdGbwOv2rJ+9x1Q9kGMJmXy5TXe3bZ0MqHj3eCpgHPkqcsGeTibb7ZRr2C
Fewq+pbtrk5EaQpR8gHCvXZx5qG3s4WnXKdUSz9HiKoAcTV/+Pxoy7M6TaLXhFcl
5gzEktDTI+CkPZ4zV/8cUnC2x4GBwZU+/R3YFHPyq2ULpUrk8P/sbLkXrelp7kgW
8ZwkWJXdfvrMVdJlLNXAN5LWBeoLbQjjuL10Uzj0cwQWC4wNR/RUpPdxpFBY7+aG
fcoz+o8tdtbPaqjjhVBJ1OlaM80AHmgp4qSZQjb5CR05EaN61yM/yxdN1uhVh0JX
jZDSlFbfS5E=
=bqth
-----END PGP SIGNATURE-----

--=-iz5Zwfz92bkXRLotlOXF--
