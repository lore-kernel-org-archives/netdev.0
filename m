From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 2/3] net: ethernet: fec: use phydev from struct
 net_device
Date: Sun, 08 May 2016 23:22:17 +0100
Message-ID: <1462746137.2634.67.camel@decadent.org.uk>
References: <1462743877-31738-1-git-send-email-tremyfr@gmail.com>
	 <1462743877-31738-3-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ha7Ejv/moTvquHsGsgRP"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Philippe Reynes <tremyfr@gmail.com>, fugang.duan@nxp.com,
	davem@davemloft.net, kan.liang@intel.com, decot@googlers.com,
	aduyck@mirantis.com, jiri@mellanox.com, jacob.e.keller@intel.com,
	tom@herbertland.com, andrew@lunn.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462743877-31738-3-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-ha7Ejv/moTvquHsGsgRP
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2016-05-08 at 23:44 +0200, Philippe Reynes wrote:
> The private structure contain a pointer to phydev, but the structure
> net_device already contain such pointer. So we can remove the pointer
> phydev in the private structure, and update the driver to use the one
> contained in struct net_device.

But there is no central code that updates the pointer, so:

[...]
> @@ -1928,7 +1926,6 @@ static int fec_enet_mii_probe(struct net_device *nd=
ev)
> =C2=A0
> =C2=A0	phy_dev->advertising =3D phy_dev->supported;
> =C2=A0
> -	fep->phy_dev =3D phy_dev;

you need to assign ndev->phydev here

[...]
> @@ -2875,8 +2869,7 @@ fec_enet_close(struct net_device *ndev)
> =C2=A0		fec_stop(ndev);
> =C2=A0	}
> =C2=A0
> -	phy_disconnect(fep->phy_dev);
> -	fep->phy_dev =3D NULL;
> +	phy_disconnect(ndev->phydev);
[...]

and you need to set it to NULL here.

Ben.
=C2=A0
--=20
Ben Hutchings
I haven't lost my mind; it's backed up on tape somewhere.
--=-ha7Ejv/moTvquHsGsgRP
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXL7wZAAoJEOe/yOyVhhEJsmgP/3lcpIiKpmVt1OaB/QvEstBh
825C+MJLsjjJZV0B3QS9p5Po5Cpd+THArw/FyuKuYUtQNwawWgMpy3xLEKRavFDK
sFCMe+0rQH4EVtvX0Hn9sHT8+q+ycUoYhqnyDcGIK6s4kY3VUz0+JlIQWlwvFIKM
jaSGaT3iY7Zu1q1AZ8TMF7AuTL1rBiEpL2mQhM6iBf1UPTm2AqJg6ix1XdTVxjfo
2T0C12c9mVGOFezrJGMlVKXlMNV0ydMZUeFtE5STZQl47ADluOo9Ln2eGaaNI3HA
ZxdJ2YbmZKcu8YrpjPLWwIRR26FCGldkKufzBmqxUq7eNd0aa3CDh2KEexX0kW0x
oP4++7CjUw9XiWh0icabM9KmSIgJh0TWw6m71IG73aYptnluheq3ZTBMiQaXu23H
Mq1DUNedoEqefqmpiTLgdemFaD4vu932tKFbW4urieyTVAnmrJK4zSilGy4A3VFP
lPqAJjjQfnFapL5BhZ5zHO/eCuY7KhTXQCKIMWPBf3SoKwD4u/sFlXCwBC82wQOQ
06zhSBaA4HXwW9V6jPE4w9Kv7dXH42hTteJ8hg4dgjS20gsvR8m9Scd1mZRU89KB
8YW8yAvQBZLpeK1dAhtE/VxSTo6w0apq1pzSAak9YViJ2htP896oQqLhLdTGJuHB
AFY8eIcj/lrFc2jjVl0X
=oZci
-----END PGP SIGNATURE-----

--=-ha7Ejv/moTvquHsGsgRP--
