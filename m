From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH] net: fec: Rename "phy-reset-active-low" property
Date: Fri, 4 Mar 2016 03:28:25 +0000
Message-ID: <VI1PR0401MB1855A52C55DA1EE8DFFF2FFFFFBE0@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1456996555-7500-1-git-send-email-bernhard@bwalle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "arnd@arndb.de" <arnd@arndb.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Bernhard Walle <bernhard@bwalle.de>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0072.outbound.protection.outlook.com ([157.56.112.72]:22457
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755790AbcCDD2a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 22:28:30 -0500
In-Reply-To: <1456996555-7500-1-git-send-email-bernhard@bwalle.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Walle <bernhard@bwalle.de> Sent: Thursday, March 03, 2016 5:16 PM
> To: davem@davemloft.net
> Cc: arnd@arndb.de; netdev@vger.kernel.org; linux-kernel@vger.kernel.org;
> Bernhard Walle <bernhard@bwalle.de>
> Subject: [PATCH] net: fec: Rename "phy-reset-active-low" property
> 
> From the perspective of RESET, the meaning of the new property is actually
> "active high". Thanks for Troy Kisky for pointing that out.
> 
> Since the patch is in linux-next, this patch is incremental and doesn't replace
> the original patch.
> 
> Signed-off-by: Bernhard Walle <bernhard@bwalle.de>
> ---
>  Documentation/devicetree/bindings/net/fsl-fec.txt | 2 +-
>  drivers/net/ethernet/freescale/fec_main.c         | 8 ++++----
>  2 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt
> b/Documentation/devicetree/bindings/net/fsl-fec.txt
> index a4799ff..b037a9d 100644
> --- a/Documentation/devicetree/bindings/net/fsl-fec.txt
> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
> @@ -12,7 +12,7 @@ Optional properties:
>    only if property "phy-reset-gpios" is available.  Missing the property
>    will have the duration be 1 millisecond.  Numbers greater than 1000 are
>    invalid and 1 millisecond will be used instead.
> -- phy-reset-active-low : If present then the reset sequence using the GPIO
> +- phy-reset-active-high : If present then the reset sequence using the
> +GPIO
>    specified in the "phy-reset-gpios" property is reversed (H=reset state,
>    L=operation state).
>  - phy-supply : regulator that powers the Ethernet PHY.
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index bad0ba2..37c0815 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -3191,7 +3191,7 @@ static int fec_enet_init(struct net_device *ndev)
> static void fec_reset_phy(struct platform_device *pdev)  {
>  	int err, phy_reset;
> -	bool active_low = false;
> +	bool active_high = false;
>  	int msec = 1;
>  	struct device_node *np = pdev->dev.of_node;
> 
> @@ -3207,17 +3207,17 @@ static void fec_reset_phy(struct platform_device
> *pdev)
>  	if (!gpio_is_valid(phy_reset))
>  		return;
> 
> -	active_low = of_property_read_bool(np, "phy-reset-active-low");
> +	active_high = of_property_read_bool(np, "phy-reset-active-high");
> 
>  	err = devm_gpio_request_one(&pdev->dev, phy_reset,
> -			active_low ? GPIOF_OUT_INIT_HIGH :
> GPIOF_OUT_INIT_LOW,
> +			active_high ? GPIOF_OUT_INIT_HIGH :
> GPIOF_OUT_INIT_LOW,
>  			"phy-reset");
>  	if (err) {
>  		dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n",
> err);
>  		return;
>  	}
>  	msleep(msec);
> -	gpio_set_value_cansleep(phy_reset, !active_low);
> +	gpio_set_value_cansleep(phy_reset, !active_high);
>  }
>  #else /* CONFIG_OF */
>  static void fec_reset_phy(struct platform_device *pdev)
> --
> 2.7.2
Rename "phy-reset-active-low" to "phy-reset-active-high" is more reasonable, not confuse us. Thanks.

Acked-by: Fugang Duan <fugang.duan@nxp.com>
