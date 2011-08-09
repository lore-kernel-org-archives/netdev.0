From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 3/4] powerpc/p1010: FlexCAN Controller for of_ type
Date: Tue, 09 Aug 2011 12:56:15 +0200
Message-ID: <4E41124F.8000608@pengutronix.de>
References: <1312815640-25804-1-git-send-email-bhaskar.upadhaya@freescale.com> <4E3FFEEB.8070400@pengutronix.de> <9C64B7751C3BCA41B64A68E23005A7BE1BF197@039-SN1MPN1-004.039d.mgd.msft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig54B23CB1AB24A879BBB6832E"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"holt@sgi.com" <holt@sgi.com>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linuxppc-release@linux.freescale.net"
	<linuxppc-release@linux.freescale.net>,
	"socketcan-core@lists.berlios.de" <socketcan-core@lists.berlios.de>
To: U Bhaskar-B22300 <B22300@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46105 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752338Ab1HIK4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2011 06:56:22 -0400
In-Reply-To: <9C64B7751C3BCA41B64A68E23005A7BE1BF197@039-SN1MPN1-004.039d.mgd.msft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig54B23CB1AB24A879BBB6832E
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 08/09/2011 12:29 PM, U Bhaskar-B22300 wrote:
>> NACK - your patch does more than the description states (debug code).
> [Bhaskar] Ok I will change description as below
> 	This patch introduces the following features
> 	1. provides the support for FlexCAN on P1010 SoC.
> 	2. Provides the common read/write interface for ARM and PowerPC based =
FlexCAN.
> 	3. Provides the clock interface for PowerPC based FlexCAN.
> 	Will it be OK ?
>=20
>> Further you still add bugs to the driver. I've send you patches to fix=

>> them.
> [Bhaskar] Please mention what sort of BUG you are seeing ..

I have, it's in that mail:

> @@ -957,24 +952,24 @@ static int __devinit register_flexcandev(struct n=
et_device *dev)
> > =20
> >  	/* select "bus clock", chip must be disabled */
> >  	flexcan_chip_disable(priv);
> > -	reg =3D readl(&regs->ctrl);
> > +	reg =3D flexcan_read(&regs->ctrl);
> >  	reg |=3D FLEXCAN_CTRL_CLK_SRC;
> > -	writel(reg, &regs->ctrl);
> > +	flexcan_write(reg, &regs->ctrl);
> > =20
> >  	flexcan_chip_enable(priv);
> > =20
> >  	/* set freeze, halt and activate FIFO, restrict register access */
> > -	reg =3D readl(&regs->mcr);
> > +	reg =3D flexcan_read(&regs->mcr);
> >  	reg |=3D FLEXCAN_MCR_FRZ | FLEXCAN_MCR_HALT |
> >  		FLEXCAN_MCR_FEN | FLEXCAN_MCR_SUPV;
> > -	writel(reg, &regs->mcr);
> > +	flexcan_write(reg, &regs->mcr);
> > =20
> >  	/*
> >  	 * Currently we only support newer versions of this core
> >  	 * featuring a RX FIFO. Older cores found on some Coldfire
> >  	 * derivates are not yet supported.
> >  	 */
> > -	reg =3D readl(&regs->mcr);
> > +	reg =3D flexcan_read(&regs->mcr);
> >  	if (!(reg & FLEXCAN_MCR_FEN)) {
> >  		dev_err(dev->dev.parent,
> >  			"Could not enable RX FIFO, unsupported core\n");
> > @@ -984,6 +979,7 @@ static int __devinit register_flexcandev(struct n=
et_device *dev)
> > =20
> >  	err =3D register_candev(dev);
> > =20
> > +	return err;
If you return here, the clock stays enabled....not good

> >   out:
> >  	/* disable core and turn off clocks */
> >  	flexcan_chip_disable(priv);
> > @@ -992,7 +988,7 @@ static int __devinit register_flexcandev(struct n=
et_device *dev)
> >  	return err;
> >  }

For reference bugreport + fix:
https://lists.berlios.de/pipermail/socketcan-core/2011-July/005838.html

cheers, Marc
--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig54B23CB1AB24A879BBB6832E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk5BElIACgkQjTAFq1RaXHOWkACeJEbjcGeHzNsxwYBMm/956w4f
1j4An3fl3jNNX1LEDnp8OgX8DHIWSuQF
=UL+q
-----END PGP SIGNATURE-----

--------------enig54B23CB1AB24A879BBB6832E--
