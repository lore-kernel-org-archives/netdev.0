From: Nicolas Ferre <nicolas.ferre@microchip.com>
Subject: Re: [PATCH] net: macb: fix phy interrupt parsing
Date: Thu, 27 Apr 2017 11:36:44 +0200
Message-ID: <c133034e-c696-f3a3-fd02-1dbf2a9552b5@microchip.com>
References: <20170426100628.14493-1-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 8bit
Cc: Bartosz Folta <bfolta@cadence.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa3.microchip.iphmx.com ([68.232.153.233]:30292 "EHLO
        esa3.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755096AbdD0JgW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 05:36:22 -0400
In-Reply-To: <20170426100628.14493-1-alexandre.belloni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 26/04/2017 à 12:06, Alexandre Belloni a écrit :
> Since 83a77e9ec415, the phydev irq is explicitly set to PHY_POLL when
> there is no pdata. It doesn't work on DT enabled platforms because the
> phydev irq is already set by libphy before.
> 
> Fixes: 83a77e9ec415 ("net: macb: Added PCI wrapper for Platform Driver.")

Means 4.10+

> Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.com>

Acked-by: Nicolas Ferre <nicolas.ferre@microchip.com>

Seems a good candidate for net stable.

Bye,

> ---
>  drivers/net/ethernet/cadence/macb.c | 18 ++++++++++--------
>  1 file changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index e131ecd17ab9..004223a866fe 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -432,15 +432,17 @@ static int macb_mii_probe(struct net_device *dev)
>  	}
>  
>  	pdata = dev_get_platdata(&bp->pdev->dev);
> -	if (pdata && gpio_is_valid(pdata->phy_irq_pin)) {
> -		ret = devm_gpio_request(&bp->pdev->dev, pdata->phy_irq_pin,
> -					"phy int");
> -		if (!ret) {
> -			phy_irq = gpio_to_irq(pdata->phy_irq_pin);
> -			phydev->irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
> +	if (pdata) {
> +		if (gpio_is_valid(pdata->phy_irq_pin)) {
> +			ret = devm_gpio_request(&bp->pdev->dev,
> +						pdata->phy_irq_pin, "phy int");
> +			if (!ret) {
> +				phy_irq = gpio_to_irq(pdata->phy_irq_pin);
> +				phydev->irq = (phy_irq < 0) ? PHY_POLL : phy_irq;
> +			}
> +		} else {
> +			phydev->irq = PHY_POLL;
>  		}
> -	} else {
> -		phydev->irq = PHY_POLL;
>  	}
>  
>  	/* attach the mac to the phy */
> 


-- 
Nicolas Ferre
