From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 4/4] net: ethoc: implement ethtool operations
Date: Thu, 30 Jan 2014 01:59:36 +0000
Message-ID: <1391047176.4405.43.camel@deadeye.wl.decadent.org.uk>
References: <1390975218-13863-1-git-send-email-jcmvbkbc@gmail.com>
	 <1390975218-13863-5-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-WNTOtI8zIiLeG1LCjeOb"
Cc: linux-xtensa@linux-xtensa.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Chris Zankel <chris@zankel.net>,
	Marc Gauthier <marc@cadence.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1390975218-13863-5-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-WNTOtI8zIiLeG1LCjeOb
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-01-29 at 10:00 +0400, Max Filippov wrote:
> The following methods are implemented:
> - get/set settings;
> - get registers length/registers;
> - get link state (standard implementation);
> - get/set ring parameters;
> - get timestamping info (standard implementation).
[...]
> --- a/drivers/net/ethernet/ethoc.c
> +++ b/drivers/net/ethernet/ethoc.c
> [...]
> +static int ethoc_get_settings(struct net_device *dev, struct ethtool_cmd=
 *cmd)
> +{
> +	struct ethoc *priv =3D netdev_priv(dev);
> +	struct phy_device *phydev =3D priv->phy;
> +
> +	if (!phydev)
> +		return -ENODEV;
> +
> +	return phy_ethtool_gset(phydev, cmd);
> +}
> +
> +static int ethoc_set_settings(struct net_device *dev, struct ethtool_cmd=
 *cmd)
> +{
> +	struct ethoc *priv =3D netdev_priv(dev);
> +	struct phy_device *phydev =3D priv->phy;
> +
> +	if (!phydev)
> +		return -ENODEV;
> +
> +	return phy_ethtool_sset(phydev, cmd);
> +}

I think these should return -EOPNOTSUPP in the PHY-less case, just as if
the set_settings pointer was not set.

[...]
> +static void ethoc_get_ringparam(struct net_device *dev,
> +				struct ethtool_ringparam *ring)
> +{
> +	struct ethoc *priv =3D netdev_priv(dev);
> +
> +	ring->rx_max_pending =3D priv->num_bd;
> +	ring->rx_mini_max_pending =3D 0;
> +	ring->rx_jumbo_max_pending =3D 0;
> +	ring->tx_max_pending =3D priv->num_bd;
> +
> +	ring->rx_pending =3D priv->num_rx;
> +	ring->rx_mini_pending =3D 0;
> +	ring->rx_jumbo_pending =3D 0;
> +	ring->tx_pending =3D priv->num_tx;
> +}
> +
> +static int ethoc_set_ringparam(struct net_device *dev,
> +			       struct ethtool_ringparam *ring)
> +{
> +	struct ethoc *priv =3D netdev_priv(dev);
> +
> +	if (netif_running(dev))
> +		return -EBUSY;

This is unhelpful.  Most implementations of this operation will restart
the interface if it's running.

> +	priv->num_tx =3D rounddown_pow_of_two(ring->tx_pending);

Range check?

> +	priv->num_rx =3D priv->num_bd - priv->num_tx;
> +	if (priv->num_rx > ring->rx_pending)
> +		priv->num_rx =3D ring->rx_pending;

So the RX ring may only ever be shrunk?!  Did you mean to compare with
priv->num_bd instead?

> +	return 0;
> +}
> +
> +const struct ethtool_ops ethoc_ethtool_ops =3D {

static

> +	.get_settings =3D ethoc_get_settings,
> +	.set_settings =3D ethoc_set_settings,
> +	.get_regs_len =3D ethoc_get_regs_len,
> +	.get_regs =3D ethoc_get_regs,
> +	.get_link =3D ethtool_op_get_link,
> +	.get_ringparam =3D ethoc_get_ringparam,
> +	.set_ringparam =3D ethoc_set_ringparam,
> +	.get_ts_info =3D ethtool_op_get_ts_info,
> +};
[...]

--=20
Ben Hutchings
It is a miracle that curiosity survives formal education. - Albert Einstein

--=-WNTOtI8zIiLeG1LCjeOb
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUumyCOe/yOyVhhEJAQrYNg/+LLced1E/VabGqvofrIOxN0a55Nz7UeAf
q2aIyDDsRa+n/vOgKeuzeFLtaAYlrVN7cgjY8PNZUq81E0chUnWhJ3tWrhJTH+uI
5DROchdSJmW+B+xsOoFHf9eM+5Wshr12hFGZlIjLfaQ4+uJHRW/DelsYlLO7kOhG
kBxV1iGtowOuHgKpUybJUvnwpdx6JGc/6DvL3YhYyWzroGZO2UhBijUVWoRx8oEu
vpiYsLg2qJPi+BlAmpBZvCHgjm4lMYRCO8uJV9t2xejkMvqoACjxYD2MT0O1FW8u
ycijS4IMXsEF9ldfNJhlQEukPO7PpLqS/uhwJoxlqnkWlv1XlOtgJ/5CMiebY/Z9
cfAB9lpy89fbTLJU5A6Scq/dZKBhD+0H+YtSfhsLh+7yVO7FfnWSba+eppwcW3dm
wAYaN94J/9gX5LtO6dQCtq+cPBis7jt988kC8WzHvsANS8ac+UY4mLVFezSQ2hCe
z8G1EPHiGR6Uz5ZPyau/nBNqVnbg3gy1ZXuDDC+BJHhn1Nc15djZbe6FazslzAnb
3N9/cID9SjB3fWPbBO6RS2AGAlYL1bX5Y5/Ab2PiZrO/5/Un0s+LWkNFSagidXCm
ZQMsSI9W9yepm/VFifMKwuzwP3nl1XqjdNTR3bBlMFPBK1ODk6Fk/60VaLOzFG70
iAQMffBFcYk=
=oMyP
-----END PGP SIGNATURE-----

--=-WNTOtI8zIiLeG1LCjeOb--
