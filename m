From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH] net:cpsw: Pass unhandled ioctl's on to generic phy ioctl
Date: Tue, 04 Feb 2014 10:50:50 +0000
Message-ID: <1391511050.3003.21.camel@deadeye.wl.decadent.org.uk>
References: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8ftSNWMZ87ivU4HxHQ3p"
Cc: mugunthanvnm@ti.com, davem@davemloft.net, netdev@vger.kernel.org
To: Stefan =?ISO-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50555 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750937AbaBDKvJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 05:51:09 -0500
In-Reply-To: <1391500242-10554-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8ftSNWMZ87ivU4HxHQ3p
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2014-02-04 at 08:50 +0100, Stefan S=C3=B8rensen wrote:
> This patch allows the use of a generic timestamping phy connected
> to the cpsw if CPTS support is not enabled.

What if CPTS support is enabled in the driver, but this particular
machine doesn't have it and uses a timestamping PHY instead?

> Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
> ---
>  drivers/net/ethernet/ti/cpsw.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cps=
w.c
> index bde63e3..a03cfb3 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1486,12 +1486,12 @@ static int cpsw_ndo_ioctl(struct net_device *dev,=
 struct ifreq *req, int cmd)
>  #endif
>  	case SIOCGMIIPHY:
>  		data->phy_id =3D priv->slaves[slave_no].phy->addr;

It looks like this existing code is broken, as the phy pointer can be
NULL!

> -		break;
> -	default:
> -		return -ENOTSUPP;
> +		return 0;
>  	}
> =20
> -	return 0;
> +	if (!priv->slaves[slave_no].phy)
> +		return -EINVAL;
> +	return phy_mii_ioctl(priv->slaves[slave_no].phy, req, cmd);

This presumably also enables SIOC{G,S}MIIREG, but you didn't mention
that.

Ben.

>  }
> =20
>  static void cpsw_ndo_tx_timeout(struct net_device *ndev)

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.

--=-8ftSNWMZ87ivU4HxHQ3p
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUvDGCue/yOyVhhEJAQqIeA//bPzG6QiVqiY/l8EoX8klfOwIbdB8CeNM
ThGJBt4SapzPOphuC08P8kR+UkdfaaClfCIlYXxaXXcy2ZUpueNFUw8PPe4hCGFg
ZTVenYPCZbsm6B7J3/yzxQZmC3iJsvOgowPmIa8XFi9LcrQa3OGfwS77g+0x03cz
QhUCf9xqk1i4wMCMSQ7hUsLUrht70l6fM+QcUzd261FMkQpdvD1iV+sv9z/60W23
XAPEyrfENr6OigZT7xQDXJQ2Ms9J4gzcvtuATLp1jJu0mAnozdaz5glpmyjlUMyB
JMScjOVvcnYICCB3l2bcxqupNukppRgMeC2hKEfsKECMWuOXRbPU+8IAh5HGZa9R
vl7Xxq32sZTSn1PEIACVLcNj3Pi1F9fqUTx2KpAjPOitgX7muKSfIn/mdVKYFyHj
a4DXtAAzsjaUQgG3grnMzFzyB4KWgi10ftp8IPynP+XyFoxSSw01s52ZVazPtFDA
uXfTPympoNU+DYMIoCHL+dM8CzU/OTZ8lNgr/eNQKgXeo0ibPMxik3kRITJNmMVZ
iMk6BuLBcey5grcKUuKhoOX+87d7+y3E7ECCPGh31HeJmtS5IauxXhLFiXXdo1C0
ZsxfJ62gvbCS0ZVzKlqnHNUs4nsAOiOV+MgamuOsnVJY7FImyCoIT9jnDbLNz720
h9HZEq2GGYg=
=HimA
-----END PGP SIGNATURE-----

--=-8ftSNWMZ87ivU4HxHQ3p--
