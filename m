From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 08/12] drivers/net/ethernet/cadence: don't use devm_pinctrl_get_select_default()
 in probe
Date: Thu, 11 Jul 2013 09:40:02 +0200
Message-ID: <51DE6152.20406@atmel.com>
References: <1373471889-18107-1-git-send-email-wsa@the-dreams.de> <1373471889-18107-8-git-send-email-wsa@the-dreams.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: Wolfram Sang <wsa@the-dreams.de>, <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1373471889-18107-8-git-send-email-wsa@the-dreams.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/07/2013 17:57, Wolfram Sang :
> Since commit ab78029 (drivers/pinctrl: grab default handles from device core),
> we can rely on device core for setting the default pins. Compile tested only.
>
> Acked-by: Linus Walleij <linus.walleij@linaro.org> (personally at LCE13)
> Signed-off-by: Wolfram Sang <wsa@the-dreams.de>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

Thanks Wolfram.

Bye,

> ---
>   drivers/net/ethernet/cadence/at91_ether.c |   11 -----------
>   1 file changed, 11 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/ethernet/cadence/at91_ether.c
> index 3f19571..bb5d63f 100644
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@ -29,7 +29,6 @@
>   #include <linux/of.h>
>   #include <linux/of_device.h>
>   #include <linux/of_net.h>
> -#include <linux/pinctrl/consumer.h>
>
>   #include "macb.h"
>
> @@ -309,7 +308,6 @@ static int __init at91ether_probe(struct platform_device *pdev)
>   	struct resource *regs;
>   	struct net_device *dev;
>   	struct phy_device *phydev;
> -	struct pinctrl *pinctrl;
>   	struct macb *lp;
>   	int res;
>   	u32 reg;
> @@ -319,15 +317,6 @@ static int __init at91ether_probe(struct platform_device *pdev)
>   	if (!regs)
>   		return -ENOENT;
>
> -	pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
> -	if (IS_ERR(pinctrl)) {
> -		res = PTR_ERR(pinctrl);
> -		if (res == -EPROBE_DEFER)
> -			return res;
> -
> -		dev_warn(&pdev->dev, "No pinctrl provided\n");
> -	}
> -
>   	dev = alloc_etherdev(sizeof(struct macb));
>   	if (!dev)
>   		return -ENOMEM;
>


-- 
Nicolas Ferre
