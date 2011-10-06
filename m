From: Wolfram Sang <w.sang@pengutronix.de>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Thu, 6 Oct 2011 11:24:57 +0200
Message-ID: <20111006092456.GB1974@pengutronix.de>
References: <4E8C78E8.3010605@hartkopp.net>
 <20111005155127.GB13794@pengutronix.de>
 <4E8C8175.2040202@hartkopp.net>
 <4E8D528D.8020607@hartkopp.net>
 <4E8D7065.8040905@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gatW/ieO32f1wygP"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andre Naujoks <nautsch@gmail.com>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:51003 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932475Ab1JFJY7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 05:24:59 -0400
Content-Disposition: inline
In-Reply-To: <4E8D7065.8040905@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--gatW/ieO32f1wygP
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


> Why do you want to change 16-bit accesses in general? They are faster
> than two 8 bit accesses.=20

Yup, was thinking the same.

>=20
> > IMHO this fix is small and clear and especially not risky. I wonder if
> > reworking the 16 bit register access is worth the effort?
>=20
> I would prefer:
>=20
>  	if (!(frame->can_id & CAN_RTR_FLAG)) {
>  		void __iomem *data =3D &regs->rx.dsr1_0;
>  		u16 *payload =3D (u16 *)frame->data;
> =20
>  		for (i =3D 0; i < frame->can_dlc / 2; i++) {
>  			*payload++ =3D in_be16(data);
>  			data +=3D 2 + _MSCAN_RESERVED_DSR_SIZE;
>  		}
> 		/* copy remaining byte */

if any

> 		if (frame->can_dlc & 1)
> 			frame->data[frame->can_dlc - 1] =3D in_8(data);

Ack.

Regards,

   Wolfram

--=20
Pengutronix e.K.                           | Wolfram Sang                |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |

--gatW/ieO32f1wygP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAk6Nc+gACgkQD27XaX1/VRvdOACeMLf46anf+iqQAS/c80Lj+oiE
Q+0AnA3b0ChPnn3UWFKk/1/+Zczru00o
=nyiH
-----END PGP SIGNATURE-----

--gatW/ieO32f1wygP--
