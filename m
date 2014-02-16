From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v3] net:cpsw: Pass unhandled ioctl's on to generic phy
 ioctl
Date: Sun, 16 Feb 2014 19:13:20 +0000
Message-ID: <1392578000.15615.117.camel@deadeye.wl.decadent.org.uk>
References: <1392558865-18388-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-bIHI7tM7gxSsq0YZMp32"
Cc: mugunthanvnm@ti.com, davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36724 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753280AbaBPTNa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 14:13:30 -0500
In-Reply-To: <1392558865-18388-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-bIHI7tM7gxSsq0YZMp32
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2014-02-16 at 14:54 +0100, Stefan S=C3=B8rensen wrote:
> This patch allows the use of a generic timestamping phy connected
> to the cpsw if CPTS support is not enabled. This also adds support
> of the SIOCGMIIREG and SIOCSMIIREG, and moves handling of SIOCGMIIPHY
> to the generic driver.
>=20
> Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>

Reviewed-by: Ben Hutchings <ben@decadent.org.uk>

> ---
> Changes since v2:
>   - Return -EOPNOTSUPP on unsupported request
> Changes since v1:
>   - Remove SIOCGMIIPHY from cpsw
>   - Mention that SIOCGMIIREG and SIOCSMIIREG support is gained
>=20
>  drivers/net/ethernet/ti/cpsw.c | 10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cps=
w.c
> index 1d860ce..39d1253 100644
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
> +		return -EOPNOTSUPP;
> +	return phy_mii_ioctl(priv->slaves[slave_no].phy, req, cmd);
>  }
> =20
>  static void cpsw_ndo_tx_timeout(struct net_device *ndev)

--=20
Ben Hutchings
Any sufficiently advanced bug is indistinguishable from a feature.

--=-bIHI7tM7gxSsq0YZMp32
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwEN0Oe/yOyVhhEJAQpJig//f+u5uYLzSeMtAdbbDP3enefAkVzr5n0g
xFaBoaEgaos7IsIHt0BObDi1FM8CgRN0B+aViF88kp4O+3vln4183PspeoftlD6B
osrmFDkDCsJRD31ZgzzhpZFJmfHk61+CcmOR/q1V7x1Tb7+bL1K/Pw+jwUpUKDCk
RRyrWhTSpXXjRmbyXgJVbapzK+iFYyopVdvEXzzy5Wlo6rN8c5POmmn1le9RagKt
44ht71riS0c6E34J6ubPbIEG109xSIRmD94NbMYFLOc279/7OVUcDkGxIn1K9fFf
yvTBd4N9vAw2QiyI9jneVS1GTmGYTzLT4YDVF2FxBhmXX7RUWayzW3tudT1HUKVy
fNurMEXs7lQWocdeon4FKfse+cjvJbxMk+LSQrcbSGKwq4VjC0zKpBrnZU396rMu
1mT9A7VY8zKxi9JTvKDcPG2G+GojUPcWpm1DInvaGggEo/Cm6wSAHIw2jQNrcqg6
S0pCbF/ST9MLW/OwLCBTKGuKBCw0A5eFkf+DUOCi1ITFY08sBGKbUkJWHoklAZ1X
AFltMnvgTe1aJaT8OplPnwnQ02e4KEHlX0NBgRMUIR1Hl7hrC3IbhyOfnPG/0TYb
6ivLEb1mqcM5azTONE0LSxVy/8UhUUbsLZePDel8pQu/L0RvePENgKulJj8CUsYY
9pgHsi9CR7o=
=Zw2P
-----END PGP SIGNATURE-----

--=-bIHI7tM7gxSsq0YZMp32--
