From: Alexandre Courbot <acourbot@nvidia.com>
Subject: Re: [PATCH] net: phy: at803x: simplify using devm_gpiod_get_optional
 and its 4th argument
Date: Sat, 28 Mar 2015 13:52:41 +0900
Message-ID: <55163399.7060404@nvidia.com>
References: <1427484302-17075-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Linus Walleij <linus.walleij@linaro.org>
To: =?UTF-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate15.nvidia.com ([216.228.121.64]:2851 "EHLO
	hqemgate15.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbbC1EwZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Mar 2015 00:52:25 -0400
In-Reply-To: <1427484302-17075-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/28/2015 04:25 AM, Uwe Kleine-K=C3=B6nig wrote:
> Since 39b2bbe3d715 (gpio: add flags argument to gpiod_get*() function=
s)
> which appeared in v3.17-rc1, the gpiod_get* functions take an additio=
nal
> parameter that allows to specify direction and initial value for outp=
ut.
> Moreover use devm_gpiod_get_index_optional instead of ignoring all
> errors returned by devm_gpiod_get. Simplify accordingly.
>
> The result is more strict error handling which is good.

Reviewed-by: Alexandre Courbot <acourbot@nvidia.com>

>
> Signed-off-by: Uwe Kleine-K=C3=B6nig <u.kleine-koenig@pengutronix.de>
> ---
>   drivers/net/phy/at803x.c | 9 +++------
>   1 file changed, 3 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index f80e19ac6704..87dd633a8d1f 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -197,15 +197,12 @@ static int at803x_probe(struct phy_device *phyd=
ev)
>   	if (!priv)
>   		return -ENOMEM;
>
> -	priv->gpiod_reset =3D devm_gpiod_get(dev, "reset");
> -	if (IS_ERR(priv->gpiod_reset))
> -		priv->gpiod_reset =3D NULL;
> -	else
> -		gpiod_direction_output(priv->gpiod_reset, 1);
> +	priv->gpiod_reset =3D devm_gpiod_get_optional(dev, "reset",
> +						    GPIOD_OUT_HIGH);
>
>   	phydev->priv =3D priv;
>
> -	return 0;
> +	return IS_ERR(priv->gpiod_reset);
>   }
>
>   static int at803x_config_init(struct phy_device *phydev)
>
-----------------------------------------------------------------------=
------------
This email message is for the sole use of the intended recipient(s) and=
 may contain
confidential information.  Any unauthorized review, use, disclosure or =
distribution
is prohibited.  If you are not the intended recipient, please contact t=
he sender by
reply email and destroy all copies of the original message.
-----------------------------------------------------------------------=
------------
