From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH] net: fec: fix phy reset operation to let imx6sl evk work
Date: Tue, 10 Sep 2013 20:48:56 +0200
Message-ID: <20130910184856.GF30088@pengutronix.de>
References: <1378804053-5094-1-git-send-email-B38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shawn.guo@linaro.org, davem@davemloft.net, netdev@vger.kernel.org,
	bhutchings@solarflare.com, stephen@networkplumber.org,
	b20596@freescale.com
To: Fugang Duan <B38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:32986 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751150Ab3IJStB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 14:49:01 -0400
Content-Disposition: inline
In-Reply-To: <1378804053-5094-1-git-send-email-B38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 10, 2013 at 05:07:33PM +0800, Fugang Duan wrote:
> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index f9aacf5..0c17df2 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -61,6 +61,7 @@
>  #include "fec.h"
>  
>  static void set_multicast_list(struct net_device *ndev);
> +static void fec_enet_reset_phy(struct platform_device *pdev);

Please move the function up and remove the prototype.

> @@ -1780,6 +1781,10 @@ fec_enet_open(struct net_device *ndev)
>  	phy_start(fep->phy_dev);
>  	netif_start_queue(ndev);
>  	fep->opened = 1;
> +
> +	/* reset phy */
> +	fec_enet_reset_phy(fep->pdev);

Drop this comment. It's very redundant to the function name.

> +static void fec_enet_reset_phy(struct platform_device *pdev)
>  {
> -	/*
> -	 * In case of platform probe, the reset has been done
> -	 * by machine code.
> -	 */
> +	struct net_device *ndev = platform_get_drvdata(pdev);
> +	struct fec_enet_private *fep = netdev_priv(ndev);
> +
> +	/* check GPIO valid to avoid kernel print warning when no gpio reset */
> +	if (gpio_is_valid(fep->phy_reset_gpio)) {
> +		gpio_set_value(fep->phy_reset_gpio, 0);
> +		msleep(fep->reset_duration);
> +		gpio_set_value(fep->phy_reset_gpio, 1);
> +	}

Drop the comment. It's obvious why it's a good idea to check for a valid
gpio.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
