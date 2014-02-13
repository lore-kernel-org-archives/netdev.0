From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2] net:cpsw: Pass unhandled ioctl's on to generic phy
 ioctl
Date: Thu, 13 Feb 2014 20:40:42 +0000
Message-ID: <1392324042.15615.53.camel@deadeye.wl.decadent.org.uk>
References: <1392301574-24233-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-37gBclAk0KFpjLjLpSrM"
Cc: mugunthanvnm@ti.com, davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:55850 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752175AbaBMUlB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 15:41:01 -0500
In-Reply-To: <1392301574-24233-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-37gBclAk0KFpjLjLpSrM
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-02-13 at 15:26 +0100, Stefan S=C3=B8rensen wrote:
> This patch allows the use of a generic timestamping phy connected
> to the cpsw if CPTS support is not enabled. This also adds support
> of the SIOCGMIIREG and SIOCSMIIREG, and moves handling of SIOCGMIIPHY
> to the generic driver.
>=20
> Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
> ---
> Changes since v1:
>   - Remove SIOCGMIIPHY from cpsw
>   - Mention that SIOCGMIIREG and SIOCSMIIREG support is gained
>=20
>  drivers/net/ethernet/ti/cpsw.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cps=
w.c
> index 1d860ce..6ecea1d 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1471,7 +1471,6 @@ static int cpsw_hwtstamp_get(struct net_device *dev=
, struct ifreq *ifr)
>  static int cpsw_ndo_ioctl(struct net_device *dev, struct ifreq *req, int=
 cmd)
>  {
>  	struct cpsw_priv *priv =3D netdev_priv(dev);
> -	struct mii_ioctl_data *data =3D if_mii(req);
>  	int slave_no =3D cpsw_slave_index(priv);
> =20
>  	if (!netif_running(dev))
> @@ -1484,14 +1483,11 @@ static int cpsw_ndo_ioctl(struct net_device *dev,=
 struct ifreq *req, int cmd)
>  	case SIOCGHWTSTAMP:
>  		return cpsw_hwtstamp_get(dev, req);
>  #endif
> -	case SIOCGMIIPHY:
> -		data->phy_id =3D priv->slaves[slave_no].phy->addr;
> -		break;
> -	default:
> -		return -ENOTSUPP;
>  	}
> =20
> -	return 0;
> +	if (!priv->slaves[slave_no].phy)
> +		return -EINVAL;

Sorry I didn't spot this before - the error code here should be
-EOPNOTSUPP.

(Note this is different from -ENOTSUPP as was used before.  That's an
NFS error code that shouldn't be seen by userland.)

Ben.

> +	return phy_mii_ioctl(priv->slaves[slave_no].phy, req, cmd);
>  }
> =20
>  static void cpsw_ndo_tx_timeout(struct net_device *ndev)

--=20
Ben Hutchings
The world is coming to an end.	Please log off.

--=-37gBclAk0KFpjLjLpSrM
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUv0tyue/yOyVhhEJAQrgAA/8Cvdenim3rTBTrxrVslwfxpEYTTcDrIDA
JblS2+w+vPMpJ6xVkmUvt47w7NeMj7ynHasI7UY888vus8E9YtQ9pzqWqrExZXOM
QTp3Ug7uR1tO1HieYnS7rzzFKdDx3hLlqFl0JSRsh06hdEybxAGuQ8vtjXfOQ7Tq
x32WAUzmB6hrbL+i9f6sghZCXz62Vg6/sp+vVAWgeKzsuJnpJGfdbmz4PBDidNdO
kEt/wp2wr1JBoxrHYYw84wFSDQTrwmZlITDfv/sW8PAQe8bYjwzkkPJPnwt2on0J
lW3PelA+9BI7t5qtLRrXOXTDO9ln21ojNBE5NjHiXxtgr4OnNBSSbNRR23eiKiQZ
0zDZ/rOivo9zOmDQhDGUW7PDuMZjwwv0DcrCRWeWdMgP8IxLinEjOyczVTlA+l59
AoLUNdhvyfcDjHgi8xY1HAJ+EF7TIhV3hg7lKvTem0ZM9Kdwuf1aCi9TdDZRuUz4
C4FosXHCcOrLQHmPqHTF8Or7PGFKikWOKcqoaysURwbBwjjLn8V6JGrJzG7W9xYt
1c+7W2fy6mQDlC3KI54isFbHEME3+N/uBgR/edwOG24YhK9GjSWvCNFIFS/50qhS
ZxTi2iP63mqk7t9CR5ud2lBiU/T1m3wAyFnI3YSn7CnpQZvkU5WeBIMb6PVag53W
fUNQ5t+rkjc=
=hcaE
-----END PGP SIGNATURE-----

--=-37gBclAk0KFpjLjLpSrM--
