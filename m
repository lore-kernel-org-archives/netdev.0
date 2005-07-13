From: David Hollis <dhollis@davehollis.com>
Subject: Re: [PATCH] forcedeth: Additional ethtool support
Date: Wed, 13 Jul 2005 08:39:21 -0400
Message-ID: <1121258362.5023.1.camel@dhollis-lnx.sunera.com>
References: <42D101EC.6000608@colorfullife.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Z/rD2cz0FCO9rdb3WWp/"
Cc: Jeff Garzik <jgarzik@pobox.com>, Netdev <netdev@oss.sgi.com>,
        renaud.lienhart@free.fr
Return-path: <netdev-bounce@oss.sgi.com>
To: Manfred Spraul <manfred@colorfullife.com>
In-Reply-To: <42D101EC.6000608@colorfullife.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-Z/rD2cz0FCO9rdb3WWp/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2005-07-10 at 13:09 +0200, Manfred Spraul wrote:

> +
> +static int nv_nway_reset(struct net_device *dev)
> +{
> +	struct fe_priv *np =3D get_nvpriv(dev);
> +	int ret;
> +
> +	spin_lock_irq(&np->lock);
> +	if (np->autoneg) {
> +		int bmcr;
> +
> +		bmcr =3D mii_rw(dev, np->phyaddr, MII_BMCR, MII_READ);
> +		bmcr |=3D (BMCR_ANENABLE | BMCR_ANRESTART);
> +		mii_rw(dev, np->phyaddr, MII_BMCR, bmcr);
> +
> +		ret =3D 0;
> +	} else {
> +		ret =3D -EINVAL;
> +	}
> +	spin_unlock_irq(&np->lock);
> +
> +	return ret;
> +}
> +

This seems almost completely generic-ified (except for the np->autoneg
part) and should be able to operate on any NIC.  Do you think there'd be
some way to whip up a stock ethtool_nway_reset() type of function that
drivers can use if they don't need to do anything fancy?  Would help
save a lot of code duplication.

--=20
David Hollis <dhollis@davehollis.com>

--=-Z/rD2cz0FCO9rdb3WWp/
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQBC1Qt5xasLqOyGHncRAp8jAJ9XLG/8d8Dkspyk3dgkxE4DLdsbogCguIYg
0GiUeyFb1vikkowDrHfdktg=
=69hb
-----END PGP SIGNATURE-----

--=-Z/rD2cz0FCO9rdb3WWp/--
