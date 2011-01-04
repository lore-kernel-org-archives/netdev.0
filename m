From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next-2.6 1/2] can: add driver for Softing card
Date: Tue, 04 Jan 2011 13:25:22 +0100
Message-ID: <4D2311B2.7000401@pengutronix.de>
References: <20101223093627.GA325@e-circ.dyndns.org> <20101223094302.GB325@e-circ.dyndns.org> <4D135BC3.6070707@pengutronix.de> <20101224091428.GA375@e-circ.dyndns.org> <4D148788.3010808@pengutronix.de> <20110104121944.GB332@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigEE2C4DD5A110CA53B8AD56C6"
Cc: socketcan-core@lists.berlios.de, netdev@vger.kernel.org
To: Kurt Van Dijck <kurt.van.dijck@eia.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:55008 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab1ADMZ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jan 2011 07:25:29 -0500
In-Reply-To: <20110104121944.GB332@e-circ.dyndns.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigEE2C4DD5A110CA53B8AD56C6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 01/04/2011 01:19 PM, Kurt Van Dijck wrote:
> On Fri, Dec 24, 2010 at 12:44:08PM +0100, Marc Kleine-Budde wrote:
>>
>>>> hmmm..all stuff behind dpram is __iomem, isn't it? I think it should=

>>>> only be accessed with via the ioread/iowrite operators. Please check=

>>> I did an ioremap_nocache. Since it is unaligned, ioread/iowrite would=
 render
>>> a lot of statements.
>>
>> The thing is, ioremapped mem should not be accessed directly. Instead
>> ioread/iowrite should be used. The softing driver should work on non x=
86
>> platforms, too.
>>
>>>> your code with sparse (compile with "make C=3D2").
>>> (?)
>>
>> Sparse, a static syntax analyser tool, see "Documentation/sparse.txt".=

>> It throws the following warnings on your driver:
>>
>>> make drivers/net/can/softing/softing.ko C=3D2
>>>   CHK     include/linux/version.h
>>>   CHK     include/generated/utsrelease.h
>>>   CALL    scripts/checksyscalls.sh
>>>   CHECK   scripts/mod/empty.c
>>>   CHECK   drivers/net/can/softing/softing_main.c
>>> drivers/net/can/softing/softing_main.c:98:15: warning: incorrect type=
 in argument 1 (different address spaces)
>>> drivers/net/can/softing/softing_main.c:98:15:    expected void volati=
le [noderef] <asn:2>*dst
>>> drivers/net/can/softing/softing_main.c:98:15:    got unsigned char [u=
sertype] *[assigned] ptr
> [...]
>>
>> You should start with fixing the assignment of the ioremapped memory
>> (drivers/net/can/softing/softing_main.c:835), the fix the rest.
>>
> (Thanks for the explanation)^2.
>=20
> I left my code now with the only warning from sparse:

Good!

> warning: Using plain integer as NULL pointer
>=20
> That means, I got all __iomem references fixed.
> Is this '0' instead of 'NULL' a big problem? I got plenty of those.

No problem for the compiler, but it's bad style :)
Please fix it.

cheers, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigEE2C4DD5A110CA53B8AD56C6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0jEbYACgkQjTAFq1RaXHOdbQCgjHlvYZksdVw8xiaGcMg3V8QK
CuEAn2jJQOeDs74egC3Vaqp6qz+CXLSK
=Gkez
-----END PGP SIGNATURE-----

--------------enigEE2C4DD5A110CA53B8AD56C6--
