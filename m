From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net: phy: fix uninitalized ethtool_wolinfo in
 phy_suspend
Date: Fri, 14 Mar 2014 14:18:06 +0000
Message-ID: <1394806686.20857.31.camel@deadeye.wl.decadent.org.uk>
References: <20140313.153832.967564223480298567.davem@davemloft.net>
	 <1394788064-6832-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-HdbWYWZmkJYw3LtGMkZ9"
Cc: David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394788064-6832-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-HdbWYWZmkJYw3LtGMkZ9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 10:07 +0100, Sebastian Hesselbarth wrote:
> Callers of phy_ethtool_get_wol are supposed to provide a properly
> cleared struct ethtool_wolinfo. Therefore, fix phy_suspend to clear
> it before passing it to phy_ethtool_get_wol.
>=20
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
> Cc: David Miller <davem@davemloft.net>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Ben Hutchings <ben@decadent.org.uk>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/phy/phy_device.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 4b03e63639b7..7512e28866f1 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -683,10 +683,9 @@ EXPORT_SYMBOL(phy_detach);
>  int phy_suspend(struct phy_device *phydev)
>  {
>  	struct phy_driver *phydrv =3D to_phy_driver(phydev->dev.driver);
> -	struct ethtool_wolinfo wol;
> +	struct ethtool_wolinfo wol =3D { .cmd =3D ETHTOOL_GWOL };
> =20
>  	/* If the device has WOL enabled, we cannot suspend the PHY */
> -	wol.cmd =3D ETHTOOL_GWOL;
>  	phy_ethtool_get_wol(phydev, &wol);
>  	if (wol.wolopts)
>  		return -EBUSY;

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-HdbWYWZmkJYw3LtGMkZ9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUyMPnue/yOyVhhEJAQod7A//ZSCIu4vNPz+Qw7EsK7DiuTJA6BNZwRTa
Ojf5s3lVq73VV8gvkLMLCdijbkCwdg+KY4oOHFfX0w97cv9OvGQaebaXrOjsu9I0
bSWxioD/HTIPJa7wySHxkgVsfeqbtTYZSXYQaYG1959oUh/wJPDEBtLMhaNMngna
hsYblLtq8/NwmgZiGBuyqwGTz8MupudSh1XavDGUxpeLOHCSUi+/T6MhlqXx1OhG
fn+jOGO/GbPJPzW6tVabeCWrF0M44Jyy9HDj2c6dsno4lPRk9zZUcGl4+JtVkVud
htn+E3Webgu2/A48Utwvb/4WxGk5mZ6TRpJoFzZT0XXzivHORwPp9/PJd4f3+svx
Zo2Tde76PbIIY+XlVwUcu83tO8veUCskJYo/R1ozZbd1OdTpPzTObDL/rSqr7f+4
RO0zn6Yx52ZkV+R1/g0BMTlJBH8ztR2VvHhN4i08iWEs4CQV+t25iPhm7F8m/GAN
C//kb1dYdMfaaXebrbmvU7R5xmVOsnkSmC0ArUvRenhoCEVO4qcMREmga7fHL12k
k+yt9jA6FouPRR9vhOaaRiXRW+BgcQIATTr+5vQxa8IQLl+0A/jISiO+fAbGonOn
v3KJVQhh8K3ZaD4otVqarKpQS49zZyzlFLVwVsxKSB4SLdaCTCtOqtbRepzZ29wa
x/iAFcCNI9g=
=Kml+
-----END PGP SIGNATURE-----

--=-HdbWYWZmkJYw3LtGMkZ9--
