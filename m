From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 06/31] net: macb: use dev_get_platdata()
Date: Fri, 30 Aug 2013 09:54:12 +0200
Message-ID: <52204FA4.3060700@atmel.com>
References: <003101cea53b$9fc95b30$df5c1190$%han@samsung.com> <005801cea53f$815de4a0$8419ade0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'David S. Miller'" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Jingoo Han <jg1.han@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:28631 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694Ab3H3HyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 03:54:14 -0400
In-Reply-To: <005801cea53f$815de4a0$8419ade0$%han@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/08/2013 07:12, Jingoo Han :
> Use the wrapper function for retrieving the platform data instead of
> accessing dev->platform_data directly. This is a cosmetic change
> to make the code simpler and enhance the readability.
>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>   drivers/net/ethernet/cadence/macb.c |    6 +++---
>   1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index fe06ab0..20f94d1 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -125,7 +125,7 @@ void macb_get_hwaddr(struct macb *bp)
>   	u8 addr[6];
>   	int i;
>
> -	pdata = bp->pdev->dev.platform_data;
> +	pdata = dev_get_platdata(&bp->pdev->dev);
>
>   	/* Check all 4 address register for vaild address */
>   	for (i = 0; i < 4; i++) {
> @@ -335,7 +335,7 @@ int macb_mii_init(struct macb *bp)
>   		bp->pdev->name, bp->pdev->id);
>   	bp->mii_bus->priv = bp;
>   	bp->mii_bus->parent = &bp->dev->dev;
> -	pdata = bp->pdev->dev.platform_data;
> +	pdata = dev_get_platdata(&bp->pdev->dev);
>
>   	bp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
>   	if (!bp->mii_bus->irq) {
> @@ -1851,7 +1851,7 @@ static int __init macb_probe(struct platform_device *pdev)
>
>   	err = of_get_phy_mode(pdev->dev.of_node);
>   	if (err < 0) {
> -		pdata = pdev->dev.platform_data;
> +		pdata = dev_get_platdata(&pdev->dev);
>   		if (pdata && pdata->is_rmii)
>   			bp->phy_interface = PHY_INTERFACE_MODE_RMII;
>   		else
>


-- 
Nicolas Ferre
