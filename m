From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Mon, 28 Aug 2017 09:02:32 +0200
Message-ID: <20170828070232.GA18135@amd>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <20170827163122.GG13622@lunn.ch>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="u3/rZRmxL6MmkK24"
Cc: Woojung.Huh@microchip.com, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170827163122.GG13622@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--u3/rZRmxL6MmkK24
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi!

Thanks for review.

> > +	case PHY_REG_STATUS:
> > +		ksz_pread8(sw, p, P_LINK_STATUS, &link);
> > +		ksz_pread8(sw, p, P_SPEED_STATUS, &speed);
> > +		data =3D PHY_100BTX_FD_CAPABLE |
> > +			PHY_100BTX_CAPABLE |
> > +			PHY_10BT_FD_CAPABLE |
> > +			PHY_10BT_CAPABLE |
> > +			PHY_AUTO_NEG_CAPABLE;
> > +		if (link & PORT_AUTO_NEG_COMPLETE)
> > +			data |=3D PHY_AUTO_NEG_ACKNOWLEDGE;
> > +		if (link & PORT_STAT_LINK_GOOD)
> > +			data |=3D PHY_LINK_STATUS;
> > +		break;
> > +	case PHY_REG_ID_1:
> > +		data =3D KSZ8895_ID_HI;
> > +		break;
> > +	case PHY_REG_ID_2:
> > +		data =3D KSZ8895_ID_LO;
> > +		break;
>=20
> According to the datasheet, the PHY has the normal ID registers,
> which have the value 0x0022, 0x1450. So it should be possible to have
> a standard PHY driver in drivers/net/phy.
>=20
> In fact, the IDs suggest it is a micrel phy, and 1430, 1435 are
> already supported. So it could be you only need minor modifications to
> the micrel.c.

I may be confused here, but AFAICT:

1) Yes, it has standard layout when accessed over MDIO. But then
there's no access to the bridging functionality, and MDIO access may
not be available. [I was told not to use it for this design, so I did
not].

2) drivers/net/phy/spi_ks8995.c can be trivially modified to work with
this chip.. but then you don't get the bridge functionality. (And I'm
not sure how it works / who translates layouts in this case.)

I'd like to get rid of this code, or use some existing code instead,
but I don't think it is possible while keeping the SPI accesss. Let me
know if I'm wrong.

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--u3/rZRmxL6MmkK24
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlmjwAgACgkQMOfwapXb+vLkEgCfTkYZDXLe8s7uiwZiS1IvTUPV
bnkAoKiCMj8xRvmMTiJbchiSEV28BD8N
=hxCI
-----END PGP SIGNATURE-----

--u3/rZRmxL6MmkK24--
