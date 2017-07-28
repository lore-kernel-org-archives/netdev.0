From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY address when
 connecting to the PHY
Date: Thu, 27 Jul 2017 18:49:05 -0700
Message-ID: <20170728014905.GC24728@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-4-antoine.tenart@free-electrons.com>
 <20170726160806.GF12049@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="KDt/GgjP6HVcx58l"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:33189 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751697AbdG1BtK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 21:49:10 -0400
Content-Disposition: inline
In-Reply-To: <20170726160806.GF12049@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--KDt/GgjP6HVcx58l
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Wed, Jul 26, 2017 at 06:08:06PM +0200, Andrew Lunn wrote:
> On Mon, Jul 24, 2017 at 03:48:33PM +0200, Antoine Tenart wrote:
> > =20
> > +	if (priv->hw_version !=3D MVPP22)
> > +		return 0;
> > +
> > +	/* Set the SMI PHY address */
> > +	if (of_property_read_u32(port->phy_node, "reg", &phy_addr)) {
> > +		netdev_err(port->dev, "cannot find the PHY address\n");
> > +		return -EINVAL;
> > +	}
> > +
> > +	writel(phy_addr, priv->iface_base + MVPP22_SMI_PHY_ADDR(port->gop_id)=
);
> >  	return 0;
> >  }
>=20
> You could use phy_dev->mdiodev->addr, rather than parse the DT.

OK.

> Why does the MAC need to know this address? The phylib and PHY driver
> should be the only thing accessing the PHY, otherwise you are asking
> for trouble.

This is part of the SMI/xSMI interface. I added into the mvpp2 driver
and not in the mvmdio one because the GoP port number must be known to
set this register (so that would be even less clean to do it).

> What if the PHY is hanging off some other mdio bus? I've got a
> freescale board with dual ethernets and a Marvell switch on the
> hardware MDIO bus and a PHY on a bit-banging MDIO bus.

Then it wouldn't be controlled by the PPv2 SMI/xSMI interface, so we
wouldn't need to set the this register.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--KDt/GgjP6HVcx58l
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAll6mBEACgkQXE2LyK3b
vNiGnQ/9EgKTCHgbu2ZgOCn+sSS/elOQyQMlWzFiPoHc9Lfkwux3Wd0AwUqUJHBF
1WvoAfiUXmGgEspZpyQYhqaztQyiSrnMB6nCW01TG1I8K4CNlV9zsgRtZpfTeDI6
DFLbBnGuOpm/iolQ+G3z6HWbLe+ONRdtoRjZrPnbqWbfpCTaTIBG0y6B3iHVHobP
3SxcfBi6At/S5jzzvwQgWshqjzW7S60FomRxX6CR++dZNeweY/GyFFYt8X6Q6n9V
bvPa31I41PhXI6JyOXmZU7YSqmtiUtLq0eGvzaXz5r3jsirzelNgiZ3sFORUc9UF
GVFWmJX/Zd8kdKeQ8LdfGYWy41rtBd8uNacphM6sTz0TcSwP6EKVBPxdgELdEU7n
OU+bvvCQUr4/9v5iY4UcA9an8iU0eomxYlWzea0iwbtW+0myrkVuC48/VzwK5Wze
Bv6Q93hMF2DzPfQ/JmKcctiHa07WncwKfi0cIGOxO6PlBcIiENr/bzzTewmk7Gf0
AdKEFDmUDzy5UHdOwhHtPDS9k0lzl7GBKE2RH5jtwFb1mCGvp1KnT/Hdx9dfj69R
BYpVzLxJUTInWsn4JKizPg0fvvedVbopVTKY0goSXnkjv3ewaBC74WssGRKPIyui
ktlqkN7R91MTg7fSaFrPo6vDfml0/w2+OwnuUxEsdfMDHOOKjvk=
=Vaet
-----END PGP SIGNATURE-----

--KDt/GgjP6HVcx58l--
