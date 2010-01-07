From: Daniel Borkmann <danborkmann@googlemail.com>
Subject: Re: [PATCH] netpoll: allow execution of multiple rx_hooks per interface
Date: Thu, 07 Jan 2010 20:06:40 +0100
Message-ID: <4B4630C0.6090206@gmail.com>
References: <4B44F895.9080205@gmail.com>	<1262836445.29868.227.camel@calx> <20100107.010201.51693251.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigB6AA20E24023CD39C718DB07"
Cc: mpm@selenic.com, danborkmann@googlemail.com,
	linux-kernel@vger.kernel.org, jmoyer@redhat.com,
	netdev@vger.kernel.org, netdev@oss.sgi.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.27]:45141 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab0AGTG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 14:06:59 -0500
In-Reply-To: <20100107.010201.51693251.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigB6AA20E24023CD39C718DB07
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

David Miller wrote:
> From: Matt Mackall <mpm@selenic.com>
> Date: Wed, 06 Jan 2010 21:54:05 -0600
>=20
>> Please inline patches so they can be reviewed easily in reply.
>>
>>
>> -       struct netpoll *np =3D npi->rx_np;
>> +       struct netpoll **np =3D &npi->rx_np;
>> =20
>> -       if (!np)
>> +       if (!(*np))
>>
>> This makes everything horrible. Can you avoid the double indirection?
>> Using a list head might be a good answer.
>>
>=20
> Agreed on all counts.
>=20

Agreed on the double indirection, I'll fix it.

I've already considered the list_head structure, but then I was the opini=
on
that a double linked list might not be necessary for this, so I did it th=
at
way ... (compare: kernel notifier by Alan Cox). If you insist on that I'l=
l
fix it of course ;)

Best regards,
Daniel

P.s.: Sorry Matt for not CCing. I mainly took those addresses from Jeffs =
post.


--------------enigB6AA20E24023CD39C718DB07
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAktGMMAACgkQ5AxJm1m3CC8G2ACdFsW7iqKqdCfc9q5Dc0Q+BPfA
IB0AoI+6DPWww3DX8LRfWeOV4vm7es85
=QDrK
-----END PGP SIGNATURE-----

--------------enigB6AA20E24023CD39C718DB07--
