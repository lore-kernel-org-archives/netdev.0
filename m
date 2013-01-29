From: Felipe Balbi <balbi@ti.com>
Subject: Re: [PATCH] net: ks8851: convert to threaded IRQ
Date: Tue, 29 Jan 2013 21:02:20 +0200
Message-ID: <20130129190220.GA6223@arwen.pp.htv.fi>
References: <20130128.223157.1855971357181002973.davem@davemloft.net>
 <1359443790-8562-1-git-send-email-balbi@ti.com>
 <51081A94.1090202@codeaurora.org>
Reply-To: <balbi@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="wRRV7LY7NUeQGEoC"
Cc: Felipe Balbi <balbi@ti.com>, <davem@davemloft.net>,
	<mjr@cs.wisc.edu>, <netdev@vger.kernel.org>
To: Stephen Boyd <sboyd@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:54696 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753701Ab3A2TCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 14:02:51 -0500
Content-Disposition: inline
In-Reply-To: <51081A94.1090202@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--wRRV7LY7NUeQGEoC
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 29, 2013 at 10:53:08AM -0800, Stephen Boyd wrote:
> On 01/28/13 23:16, Felipe Balbi wrote:
> > just as it should have been. It also helps
> > removing the, now unnecessary, workqueue.
>=20
> Tested-by: Stephen Boyd <sboyd@codeaurora.org>
>=20
> > Signed-off-by: Felipe Balbi <balbi@ti.com>
> > ---
> > @@ -1505,8 +1485,9 @@ static int ks8851_probe(struct spi_device *spi)
> >  	ks8851_read_selftest(ks);
> >  	ks8851_init_mac(ks);
> > =20
> > -	ret =3D request_irq(spi->irq, ks8851_irq, IRQF_TRIGGER_LOW,
> > -			  ndev->name, ks);
> > +	ret =3D request_threaded_irq(spi->irq, NULL, ks8851_irq,
> > +				   IRQF_TRIGGER_LOW | IRQF_ONESHOT,
> > +				   ndev->name, ks);
>=20
> I did notice one thing here. The name of the thread is irq/378-eth%d
> (where 378 is the irq number). It seems that ndev->name is not fully
> formed until register_netdev() is called and so when the thread is
> created, the malformed name is used for the thread name.

that would be a problem even before the conversion to threaded irq, the
only difference is that 378- would be omitted.

--=20
balbi

--wRRV7LY7NUeQGEoC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBAgAGBQJRCBy8AAoJEIaOsuA1yqRE4JgQAKSgeiDG6Bchyi49qkPRduAb
KlD3e6J5sZp6VtyH7SDNX1qgFxgOktR/VE+nJ38DC/1WFgom6cUhoCCBHjEOpaLx
sfPpvk2zEnIGivkqRpUmXo0P5ygtMvrg4JlkpjOCfrI9r6OIBnWBmx0o4GAa4DYY
uphLZRY9WE+ssXU/JK4PVMLqk6hJIUZ1p1azSFGQs11bvLAwyuL950trappVBX9Z
ALxQnqHXMIz3i/qoclcC4Non7aS7BgkVTuzGHu9WlDnCqWVqludRvEe0G+QDWs1O
ERNDJ8Algy7Yz0IRrkVuukUwSOrJnPb9arCm2jF1WWM6baXIOcmhZG6n1THpOSsl
ujHOk9wlOrXzMxW7gGJzcGZIhhYXEV6g5RYlZakNcG0BMgW1C1VEAhTdLQtjEMdF
lpBajYritzB5pW05C2mmmn7mYLtN3BY8GJIXuJ/gxJ5FRqBcSNuGs1G4rtP3yBhk
mOnZFgTgJSKLkzA6utjaui4p877KHCMn+kBzAFNO/7wE/LuhdP3uLxY5nYQ++bNY
YCHdwXDjssWssWj2uCDzyjKJrmakdSoBJNDAUixSx7rBzkZYpGlijGVsnPbAt45x
fGWtGASUbvOQhtkyfvKuPDJggPqJJLa2g2bYW4qoRPmfunbQbcx4l/0eZQMFnTwe
YN8io/UV42ymPf6a3aEk
=YPU5
-----END PGP SIGNATURE-----

--wRRV7LY7NUeQGEoC--
