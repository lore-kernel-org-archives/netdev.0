From: Nigel Cunningham <nigel@nigel.suspend2.net>
Subject: Re: [RFC][PATCH] Add suspend and resume support to uli526x
Date: Tue, 05 Jun 2007 08:55:25 +1000
Message-ID: <1180997725.4356.77.camel@nigel.suspend2.net>
References: <200706031237.36773.rjw@sisk.pl>
	 <20070604111112.GP4363@elf.ucw.cz> <200706041549.11277.rjw@sisk.pl>
	 <1180991794.4356.31.camel@nigel.suspend2.net>
	 <20070604224146.GE2711@elf.ucw.cz>
	 <1180997344.4356.74.camel@nigel.suspend2.net>
	 <20070604225303.GG2711@elf.ucw.cz>
Reply-To: nigel@nigel.suspend2.net
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-IgQhIv85iwn/HBZtTcuj"
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-pm <linux-pm@lists.osdl.org>, netdev@vger.kernel.org,
	Valerie Henson <val@nmt.edu>, Peer Chen <peer.chen@uli.com.tw>
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nigel.suspend2.net ([203.171.70.205]:32958 "EHLO
	nigel.suspend2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753564AbXFDWzZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 18:55:25 -0400
In-Reply-To: <20070604225303.GG2711@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-IgQhIv85iwn/HBZtTcuj
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi.

On Tue, 2007-06-05 at 00:53 +0200, Pavel Machek wrote:
> On Tue 2007-06-05 08:49:04, Nigel Cunningham wrote:
> > Hi.
> >=20
> > On Tue, 2007-06-05 at 00:41 +0200, Pavel Machek wrote:
> > > Hi!
> > >=20
> > > > > > > +#endif /* CONFIG_PM */
> > > > > >=20
> > > > > > > @@ -1689,6 +1775,10 @@ static struct pci_driver uli526x_drive=
r=20
> > > > > > >  	.id_table	=3D uli526x_pci_tbl,
> > > > > > >  	.probe		=3D uli526x_init_one,
> > > > > > >  	.remove		=3D __devexit_p(uli526x_remove_one),
> > > > > > > +#ifdef CONFIG_PM
> > > > > > > +	.suspend	=3D uli526x_suspend,
> > > > > > > +	.resume		=3D uli526x_resume,
> > > > > > > +#endif
> > > > > >=20
> > > > > > ...so that this ifdef is not needed?
> > > > >=20
> > > > > OK, why not.
> > > >=20
> > > > Because it's uglier and #ifdef is the established way of doing thin=
gs?
> > >=20
> > > Actually the way I suggested is nicer, IIRC akpm invented it. It keep=
s
> > > ifdefs localized around the block that _needs_ to be ifdefed.
> >=20
> > The localised point is true. I'll also admit that 'nicer'/'uglier' is a
> > matter of aesthetics and therefore personal opinion.
> >=20
> > I guess that leaves the question, "What's the precedent to follow?" or
> > "Is there a driver that's already got this new format?".
>=20
> for example net/ne.c ...
>=20
> pavel@amd:/data/l/linux/drivers$ grep "_suspend NULL" */*.c
> leds/leds-ams-delta.c:#define ams_delta_led_suspend NULL
> leds/leds-net48xx.c:#define net48xx_led_suspend NULL
> leds/leds-s3c24xx.c:#define s3c24xx_led_suspend NULL
> leds/leds-tosa.c:#define tosaled_suspend NULL
> leds/leds-wrap.c:#define wrap_led_suspend NULL
> misc/tifm_7xx1.c:#define tifm_7xx1_suspend NULL
> misc/tifm_core.c:#define tifm_device_suspend NULL
> net/3c509.c:#define el3_suspend NULL
> net/forcedeth.c:#define nv_suspend NULL
> net/ne.c:#define ne_drv_suspend NULL
> parport/parport_ax88796.c:#define parport_ax88796_suspend NULL
> rtc/rtc-at91rm9200.c:#define at91_rtc_suspend NULL
> rtc/rtc-omap.c:#define omap_rtc_suspend NULL
> rtc/rtc-s3c.c:#define s3c_rtc_suspend NULL
> serial/8250_pnp.c:#define serial_pnp_suspend NULL
> serial/atmel_serial.c:#define atmel_serial_suspend NULL
> serial/s3c2410.c:#define s3c24xx_serial_suspend NULL
> spi/pxa2xx_spi.c:#define pxa2xx_spi_suspend NULL
> spi/spi_bfin5xx.c:#define bfin5xx_spi_suspend NULL
> spi/spi_imx.c:#define spi_imx_suspend NULL
> spi/spi_s3c24xx.c:#define s3c24xx_spi_suspend NULL
> spi/spi_s3c24xx_gpio.c:#define s3c2410_spigpio_suspend NULL
> video/arkfb.c:#define ark_pci_suspend NULL
> video/au1100fb.c:#define au1100fb_drv_suspend NULL
> video/s3c2410fb.c:#define s3c2410fb_suspend NULL
> video/skeletonfb.c:#define xxxfb_suspend NULL
> video/skeletonfb.c:#define xxxfb_suspend NULL
> video/sm501fb.c:#define sm501fb_suspend NULL

Cool. That's a lot more than I would have expected. Ok. I'll drop my
objection then. (Still think it's ugly though :>).

Regards,

Nigel

--=-IgQhIv85iwn/HBZtTcuj
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGZJhdN0y+n1M3mo0RAhBsAKDVtMJppdfV4oQ1RM2NMnGIQT0/OwCgrqO5
aEi47cIR7+dSrfNiIhw8B6M=
=Tq9j
-----END PGP SIGNATURE-----

--=-IgQhIv85iwn/HBZtTcuj--

