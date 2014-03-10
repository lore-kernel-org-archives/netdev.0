From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: phy: fix uninitalized WOL parameters in
 phy_ethtool_get_wol
Date: Mon, 10 Mar 2014 23:18:40 +0000
Message-ID: <1394493520.23624.22.camel@deadeye.wl.decadent.org.uk>
References: <1394413270-7169-1-git-send-email-sebastian.hesselbarth@gmail.com>
	 <1394419893.15968.88.camel@deadeye.wl.decadent.org.uk>
	 <531D98D1.4000707@gmail.com>
	 <20140310.162349.2007153760780671206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-r7OroUKBBsRLjG3mP3hZ"
Cc: sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140310.162349.2007153760780671206.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-r7OroUKBBsRLjG3mP3hZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-03-10 at 16:23 -0400, David Miller wrote:
> From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Date: Mon, 10 Mar 2014 10:49:53 +0000
>=20
> > void phy_ethtool_get_wol(struct phy_device *phydev, struct
> > ethtool_wolinfo *wol)
> > {
> >       memset(wol, 0, sizeof(*wol));
> >=20
> >       if (phydev && phydev->drv->get_wol)
> >               phydev->drv->get_wol(phydev, wol);
> > }
> >=20
> > That would also simplify above drivers down to e.g:
> >=20
> > static void cpsw_get_wol(struct net_device *ndev, struct
> > ethtool_wolinfo *wol)
> > {
> >       struct cpsw_priv *priv =3D netdev_priv(ndev);
> >       int slave_no =3D cpsw_slave_index(priv);
> >       phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
> > }
> >=20
> > instead of:
> >=20
> > static void cpsw_get_wol(struct net_device *ndev, struct
> > ethtool_wolinfo *wol)
> > {
> >       struct cpsw_priv *priv =3D netdev_priv(ndev);
> >       int slave_no =3D cpsw_slave_index(priv);
> >=20
> >       wol->supported =3D 0;
> >       wol->wolopts =3D 0;
> >=20
> >       if (priv->slaves[slave_no].phy)
> >               phy_ethtool_get_wol(priv->slaves[slave_no].phy, wol);
> > }
>=20
> Agreed, since phy_ethtool_get_wol() is the common routine used by the dri=
vers,
> we should make it clear the structure.

No, ethtool_get_wol() is the common routine used by *all* the drivers
and it initialises the struct properly.

Ben.

--=20
Ben Hutchings
Computers are not intelligent.	They only think they are.

--=-r7OroUKBBsRLjG3mP3hZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUx5IUOe/yOyVhhEJAQpVIw//XXBiJZFIo0w3xLC3YOvASK4iRz4WCcKP
mMTJufmZ9345qcmJJSmysEzzGq/sfhpTYpUQmAxAzHbNvwOOKDC2/5N/6K0m7sPG
C+AjbZOu8wbduQv6D8H9y5sNAVB+shtg+Wats4LEBQSA3fHSvYqKYp1O8lFFysB1
Mu4Aob20fSv1YxHR66d4qdyS4waVmbjKwk7miVzVqKUTVHsIhJTsvSpIHTBtQGOr
1CZq6emjdM4UQqgV37SumLBDfMja/F7r7PnfM6h+TdQn2O9phlHHI7wiDXJnCS4Z
yRJTTmkILQKzEEfjA28YB2PTw6lyg6GSJrBE1L9Y6xbcs3dZqw35Wg9kgIBa4BXG
MAIMsgi18nEzt345OBAlSwhbDDMSVFdZOU6f6kYRJ4IAC7X1vcTmUOhryU/60dRw
OgOgu50Jm9TB9PTbcX+as5iZtKNLuK4Sq1qKJ4mJUD5iVkn0FTPi418AUqMO08Ec
iFOMsAwxqM9QSGzKxW2//i5fn9NePuh2S81DHre+iSCFn6CMNw7PHb76UjWOIvQd
Fkh7deZeVOX4E9SqK4AFxCweFS0pilezS4y6RKih1z9yfk9pxYKVtQnbOna1zGzO
V1aKMyJ6GVBtvP/J7Zszp8VkBDMEuPQhIX2zE1KSve+zuZGrl0y5AazWiJrMusRG
enAxdr9q5xI=
=/suy
-----END PGP SIGNATURE-----

--=-r7OroUKBBsRLjG3mP3hZ--
