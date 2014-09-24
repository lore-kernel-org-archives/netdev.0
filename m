From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] Revert "net/macb: add pinctrl consumer support"
Date: Wed, 24 Sep 2014 17:28:53 +0200
Message-ID: <5422E335.2020907@atmel.com>
References: <1411429748-31444-1-git-send-email-soren.brinkmann@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Soren Brinkmann <soren.brinkmann@xilinx.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1411429748-31444-1-git-send-email-soren.brinkmann@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 23/09/2014 01:49, Soren Brinkmann :
> This reverts commit 8ef29f8aae524bd51298fb10ac6a5ce6c4c5a3d8.
> The driver core already calls pinctrl_get() and claims the default
> state. There is no need to replicate this in the driver.
> ---
> Hi,
> 
> I might be mistaken, but I think the driver core does already take care of
> calling into the pinctrl framework and the driver does not need to do it on its
> own (drivers/base/dd.c:really_probe() calls 'pinctrl_bind_pins() which takes
> care of the pinctrl setup).

True, thanks for your patch:

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>


>  drivers/net/ethernet/cadence/macb.c | 11 -----------
>  1 file changed, 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index ca5d7798b265..e1e02fba4fcc 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -30,7 +30,6 @@
>  #include <linux/of_device.h>
>  #include <linux/of_mdio.h>
>  #include <linux/of_net.h>
> -#include <linux/pinctrl/consumer.h>
>  
>  #include "macb.h"
>  
> @@ -2071,7 +2070,6 @@ static int __init macb_probe(struct platform_device *pdev)
>  	struct phy_device *phydev;
>  	u32 config;
>  	int err = -ENXIO;
> -	struct pinctrl *pinctrl;
>  	const char *mac;
>  
>  	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
> @@ -2080,15 +2078,6 @@ static int __init macb_probe(struct platform_device *pdev)
>  		goto err_out;
>  	}
>  
> -	pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
> -	if (IS_ERR(pinctrl)) {
> -		err = PTR_ERR(pinctrl);
> -		if (err == -EPROBE_DEFER)
> -			goto err_out;
> -
> -		dev_warn(&pdev->dev, "No pinctrl provided\n");
> -	}
> -
>  	err = -ENOMEM;
>  	dev = alloc_etherdev(sizeof(*bp));
>  	if (!dev)
> 


-- 
Nicolas Ferre
