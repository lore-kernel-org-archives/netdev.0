From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY address when
 connecting to the PHY
Date: Tue, 22 Aug 2017 16:41:01 +0200
Message-ID: <20170822144101.GC14942@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-4-antoine.tenart@free-electrons.com>
 <20170726160806.GF12049@lunn.ch>
 <20170728014905.GC24728@kwain>
 <20170728042153.GH18666@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="E/DnYTRukya0zdZ1"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:33464 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932785AbdHVOlC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 10:41:02 -0400
Content-Disposition: inline
In-Reply-To: <20170728042153.GH18666@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--E/DnYTRukya0zdZ1
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Fri, Jul 28, 2017 at 06:21:53AM +0200, Andrew Lunn wrote:
> On Thu, Jul 27, 2017 at 06:49:05PM -0700, Antoine Tenart wrote:
> > On Wed, Jul 26, 2017 at 06:08:06PM +0200, Andrew Lunn wrote:
> > > On Mon, Jul 24, 2017 at 03:48:33PM +0200, Antoine Tenart wrote:
> > > > =20
> > > > +	if (priv->hw_version !=3D MVPP22)
> > > > +		return 0;
> > > > +
> > > > +	/* Set the SMI PHY address */
> > > > +	if (of_property_read_u32(port->phy_node, "reg", &phy_addr)) {
> > > > +		netdev_err(port->dev, "cannot find the PHY address\n");
> > > > +		return -EINVAL;
> > > > +	}
> > > > +
> > > > +	writel(phy_addr, priv->iface_base + MVPP22_SMI_PHY_ADDR(port->gop=
_id));
> > > >  	return 0;
> > > >  }
> > >=20
> > > Why does the MAC need to know this address? The phylib and PHY driver
> > > should be the only thing accessing the PHY, otherwise you are asking
> > > for trouble.
> >=20
> > This is part of the SMI/xSMI interface. I added into the mvpp2 driver
> > and not in the mvmdio one because the GoP port number must be known to
> > set this register (so that would be even less clean to do it).
>=20
> It is still not clear to my why you need to program the address into
> the hardware. Is the hardware talking to the PHY?

Sorry for the answer delay, I was out of the office...

This PHY address configuration should be done in the mvmdio driver as
this is not directly related to the PPv2 (well, the mvmdio driver is
only an abstraction to reuse the mdio code, using registers exposed by
PPv2 in this case anyway). But two values must be known in order to do
this: the PHY address and the GoP port number. Getting the last one from
the mvmdio driver would be really ugly as we would need to read the PPv2
dt node. This is why this patch adds it in the PPv2 driver, but I know
it's not perfect.

I'll resend a series very soon, with this patch still included. We can
continue the discussion there I guess, if needed.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--E/DnYTRukya0zdZ1
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAlmcQnwACgkQXE2LyK3b
vNhqNA//UrpNiykQufzngLoWeQwHoGwaSqj77UXK8iAgYF04rA8LqntWUZD6RS06
NnZviNex5mKN5KDAxSib/8pJmViYPoxwhykw4efors0oOGwOgr5vY6JfWpet+riE
6XNfxcLpL7wRw5WsNCno4Ak1q7bIQ5mrjIliSPXxPO3A6QPntdTlhnoOuexqa2NF
6HkcbbuFH2MuVaLY13jBDVsjNoLioQqJfv/oETwWH3+4dnFyRHnkCRAifGG0jJ0a
HHEWlD5jZsRlqvzLF2I6H4HLIXK6yxFT4P5fbrxLANRWgZgH/URvl2wxCqqh2Qy1
EDmtMfNgSUjBinWSLencc6ipeVf/uRzCTboZigUORtwiNhsbZVgwAUq9DTFzSlBN
6dxyJZILgiRYWoGL9DTkFX4kGsIMlhPwxddi/VHYhinQxZdJzPjIgwyRsMnM8Fw5
98vlNJ1mkk6WijdeNN18fj+015YLoNlF02u8D0YFi9qYnIO96qDQYP6WLZzAAvcN
iGEQ4fEC7Jppul1vmhH3ADLcR7Zu5Bxz+IN1UEelGg4cDgjB5noiSdzNoZyABcm+
fqmkX0AicuiaEnEJ4tB2dveoBKtNUuVxes8wVhPP1xlnTTiB6BDsygv9+vAsqIje
iK/yBGPEoVGemZFraPpI7p8aUtSls04ptjE13SnhHxhlqrpIics=
=m1se
-----END PGP SIGNATURE-----

--E/DnYTRukya0zdZ1--
