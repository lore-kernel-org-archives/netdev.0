From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH] net: phy: at803x: don't depend on GPIOLIB
Date: Fri, 18 Mar 2016 13:12:54 +0100
Message-ID: <56EBF0C6.6080905@free.fr>
References: <56E99727.9040702@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Uwe Kleine-Koenig <u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Daniel Mack <daniel@zonque.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mans Rullgard <mans@mansr.com>,
	Fabio Estevam <festevam@gmail.com>,
	Martin Blumenstingl <martin.blumenstingl@gmail.com>
To: Sebastian Frias <sf84@laposte.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:15601 "EHLO smtp2-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514AbcCRMNK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 08:13:10 -0400
In-Reply-To: <56E99727.9040702@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ CCing a few devs who might be interested ]

On 16/03/2016 18:25, Sebastian Frias wrote:

> Commit 687908c2b649 ("net: phy: at803x: simplify using
> devm_gpiod_get_optional and its 4th argument") introduced a dependency
> on GPIOLIB that was not there before.
> 
> This commit removes such dependency by checking the return code and
> comparing it against ENOSYS which is returned when GPIOLIB is not
> selected.
> 
> Fixes: 687908c2b649 ("net: phy: at803x: simplify using
> devm_gpiod_get_optional and its 4th argument")
> 
> Signed-off-by: Sebastian Frias <sf84@laposte.net>
> ---
>  drivers/net/phy/at803x.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index 2174ec9..88b7ff3 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -252,7 +252,9 @@ static int at803x_probe(struct phy_device *phydev)
>  		return -ENOMEM;
> 
>  	gpiod_reset = devm_gpiod_get_optional(dev, "reset", GPIOD_OUT_HIGH);
> -	if (IS_ERR(gpiod_reset))
> +	if (PTR_ERR(gpiod_reset) == -ENOSYS)
> +		gpiod_reset = NULL;
> +	else if (IS_ERR(gpiod_reset))
>  		return PTR_ERR(gpiod_reset);
> 
>  	priv->gpiod_reset = gpiod_reset;
> 
