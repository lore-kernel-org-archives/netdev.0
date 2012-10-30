From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 1/1] net: macb: add pinctrl consumer support
Date: Tue, 30 Oct 2012 11:47:16 +0100
Message-ID: <508FB034.70004@atmel.com>
References: <1351352997-31116-1-git-send-email-plagnioj@jcrosoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>
To: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:27722 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757067Ab2J3JrM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 05:47:12 -0400
In-Reply-To: <1351352997-31116-1-git-send-email-plagnioj@jcrosoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/2012 05:49 PM, Jean-Christophe PLAGNIOL-VILLARD :
> If no pinctrl available just report a warning as some architecture may not
> need to do anything.
> 
> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> ---
>  drivers/net/ethernet/cadence/macb.c |   13 +++++++++++++
>  1 file changed, 13 insertions(+)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 033064b..e5fdf8a 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -26,6 +26,9 @@
>  #include <linux/of.h>
>  #include <linux/of_device.h>
>  #include <linux/of_net.h>
> +#include <linux/of_gpio.h>
> +#include <linux/gpio.h>
> +#include <linux/pinctrl/consumer.h>
>  
>  #include "macb.h"
>  
> @@ -1306,6 +1309,7 @@ static int __init macb_probe(struct platform_device *pdev)
>  	struct phy_device *phydev;
>  	u32 config;
>  	int err = -ENXIO;
> +	struct pinctrl *pinctrl;
>  
>  	regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	if (!regs) {
> @@ -1313,6 +1317,15 @@ static int __init macb_probe(struct platform_device *pdev)
>  		goto err_out;
>  	}
>  
> +	pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
> +	if (IS_ERR(pinctrl)) {
> +		err = PTR_ERR(pinctrl);
> +		if (err == -EPROBE_DEFER)
> +			return err;

I will modify this to be consistent with error path before and after
this change => goto err_out.
Do not bother to re-submit a patch, I will include this one in my
upcoming patch series.

Thanks,

> +
> +		dev_warn(&pdev->dev, "No pinctrl provided\n");
> +	}
> +
>  	err = -ENOMEM;
>  	dev = alloc_etherdev(sizeof(*bp));
>  	if (!dev)
> 


-- 
Nicolas Ferre
