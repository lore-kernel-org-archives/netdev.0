From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH] at803x: fix reset handling
Date: Wed, 23 Mar 2016 07:45:04 +0100
Message-ID: <20160323064504.GI6191@pengutronix.de>
References: <1525241.UQIRf9ZOB3@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	Daniel Mack <zonque@gmail.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:37717 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751234AbcCWGpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Mar 2016 02:45:06 -0400
Content-Disposition: inline
In-Reply-To: <1525241.UQIRf9ZOB3@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I added the author of 13a56b449325 to Cc.

On Wed, Mar 23, 2016 at 12:44:40AM +0300, Sergei Shtylyov wrote:
> The driver of course "knows" that the chip's reset signal is active l=
ow,
> so  it drives the GPIO to 0  to reset the PHY and to 1 otherwise; how=
ever
> all this will only work iff the GPIO  is  specified as active-high in=
 the
> device tree!  I think both the driver and the device trees (if there =
are
> any -- I was unable to find them) need to be fixed in this case...
>=20
> Fixes: 13a56b449325 ("net: phy: at803x: Add support for hardware rese=
t")
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>=20
> ---
> The patch is against DaveM's 'net.git' repo.

Don't you need to work against net-next for non-urgent stuff? Or do you
consider this urgent?

>  drivers/net/phy/at803x.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>=20
> Index: net/drivers/net/phy/at803x.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- net.orig/drivers/net/phy/at803x.c
> +++ net/drivers/net/phy/at803x.c
> @@ -277,7 +277,7 @@ static int at803x_probe(struct phy_devic
>  	if (!priv)
>  		return -ENOMEM;
> =20
> -	gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HIG=
H);
> +	gpiod_reset =3D devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_LOW=
);
>  	if (IS_ERR(gpiod_reset))
>  		return PTR_ERR(gpiod_reset);
> =20
> @@ -362,10 +362,10 @@ static void at803x_link_change_notify(st
> =20
>  				at803x_context_save(phydev, &context);
> =20
> -				gpiod_set_value(priv->gpiod_reset, 0);
> -				msleep(1);
>  				gpiod_set_value(priv->gpiod_reset, 1);
>  				msleep(1);
> +				gpiod_set_value(priv->gpiod_reset, 0);
> +				msleep(1);

The new variant is better than the old one. The change however breaks
existing device trees which is not so nice. Given there are no mainline
users this is probably ok though. So:

Acked-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
