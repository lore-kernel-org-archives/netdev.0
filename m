From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 2/4] net: ethoc: implement ethtool get/set settings
Date: Fri, 31 Jan 2014 18:03:03 +0000
Message-ID: <1391191383.4405.83.camel@deadeye.wl.decadent.org.uk>
References: <1391146867-30508-1-git-send-email-jcmvbkbc@gmail.com>
	 <1391146867-30508-3-git-send-email-jcmvbkbc@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-0DRz3IWApEQVGdLXE1zW"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Marc Gauthier <marc@cadence.com>
To: Max Filippov <jcmvbkbc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1391146867-30508-3-git-send-email-jcmvbkbc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-0DRz3IWApEQVGdLXE1zW
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-01-31 at 09:41 +0400, Max Filippov wrote:
> Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
> Changes v1->v2:
> - fix {get,set}_settings return code in case there's no PHY.
>=20
>  drivers/net/ethernet/ethoc.c | 24 ++++++++++++++++++++++++
>  1 file changed, 24 insertions(+)
>=20
> diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
> index 0623c20..779d3c3 100644
> --- a/drivers/net/ethernet/ethoc.c
> +++ b/drivers/net/ethernet/ethoc.c
> @@ -890,7 +890,31 @@ out:
>  	return NETDEV_TX_OK;
>  }
> =20
> +static int ethoc_get_settings(struct net_device *dev, struct ethtool_cmd=
 *cmd)
> +{
> +	struct ethoc *priv =3D netdev_priv(dev);
> +	struct phy_device *phydev =3D priv->phy;
> +
> +	if (!phydev)
> +		return -EOPNOTSUPP;
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
> +		return -EOPNOTSUPP;
> +
> +	return phy_ethtool_sset(phydev, cmd);
> +}
> +
>  const struct ethtool_ops ethoc_ethtool_ops =3D {
> +	.get_settings =3D ethoc_get_settings,
> +	.set_settings =3D ethoc_set_settings,
>  	.get_link =3D ethtool_op_get_link,
>  	.get_ts_info =3D ethtool_op_get_ts_info,
>  };

--=20
Ben Hutchings
It is easier to write an incorrect program than to understand a correct one=
.

--=-0DRz3IWApEQVGdLXE1zW
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUuvlV+e/yOyVhhEJAQqa5A//VeJVtFoD5yLhcrp3XWsv2zOpkE+nCrPa
SMVdsxSrIT7Na0MMRji4918It4offs9CaUh+kUtnAQ6A94cpwGq5EUC/s+4A+wLT
OU+eiccyQ7w5Zn+QXqbVRHD3/n7E4GdWA3/MfFq5kv/DAQBh/kZrEmQBJs2BnNvG
5+FNEHV8BwUl0kP3QxvUz6OjW4M2gn46OEIclMHhWw9DOgCvaZgOSmlnz4PFi9ut
iyoOtODK5r7bD1uWHZUDQG7f3o9+zLrpmYr/sSpTSnYkNcZ1MNipZR3WNYIoOaxH
JsYwCO+L+v8axWQCU3IVR8rvoW9wLph3GIurFteOWg2iE19ufL8W9D1I9vNfFLAX
geY9vSgpgw/M7dF3t66EJ8FDsckg2EaHAaHY6lW+jsJ300FeRPN1ty+CIviXbLHb
25ZlEQqzKlN0CnnNy1N+eKOkRmY4StnyqXlo0t7Oi3XJKM/93b6D+Pt7c0YExmRy
s0HGQ8xZCKu5I/8X26HBY/lbzdqhy01/O9scKux4uXY6bkLVKwrOAAvNc6SU5Fd/
VmrecDeSPq3S8rJADd0H7eVtF7iuzm8aANqtl7V476jHiKpx6ghcRtvDdauegx0d
gXaH7dCeIWQTmMp/NUJcIi2VXcRyyjLrWjTj35ze/FjsK/rVScGoCAXJ7bTJHhRD
3jFQWhFMvvA=
=RRYS
-----END PGP SIGNATURE-----

--=-0DRz3IWApEQVGdLXE1zW--
