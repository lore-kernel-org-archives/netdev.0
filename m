From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 08/24] phy: Centralise print about attached
 phy
Date: Mon, 04 Jan 2016 12:15:50 -0800
Message-ID: <568AD2F6.2090006@gmail.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch> <1451929022-5580-9-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33322 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752646AbcADUQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 15:16:21 -0500
Received: by mail-pa0-f66.google.com with SMTP id pv5so16607021pac.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 12:16:21 -0800 (PST)
In-Reply-To: <1451929022-5580-9-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/01/16 09:36, Andrew Lunn wrote:
> Many Ethernet drivers contain the same netdev_info() print statement
> about the attached phy. Move it into the phy device code.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---

[snip]

> diff --git a/drivers/net/ethernet/adi/bfin_mac.c b/drivers/net/ethernet/adi/bfin_mac.c
> index 5f8a5182b8dc..4c6f7a7f9352 100644
> --- a/drivers/net/ethernet/adi/bfin_mac.c
> +++ b/drivers/net/ethernet/adi/bfin_mac.c
> @@ -444,11 +444,6 @@ static int mii_probe(struct net_device *dev, int phy_mode)
>  	lp->old_duplex = -1;
>  	lp->phydev = phydev;
>  
> -	pr_info("attached PHY driver [%s] "
> -	        "(mii_bus:phy_addr=%s, irq=%d, mdc_clk=%dHz(mdc_div=%d)@sclk=%dMHz)\n",
> -		phydev->drv->name, phydev_name(phydev), phydev->irq,
> -	        MDC_CLK, mdc_div, sclk/1000000);

Removing this gets rid of the bus clocking information that is displayed
here.

[snip]

>  	/* mask with MAC supported features */
>  	phydev->supported &= PHY_BASIC_FEATURES;
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 0f179709a289..e41bea8e898d 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -662,6 +662,10 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  	phydev->attached_dev = dev;
>  	dev->phydev = phydev;
>  
> +	netdev_info(dev,
> +		    "attached PHY driver [%s] (mii_bus:phy_addr=%s, irq=%d)\n",
> +		    phydev->drv->name, phydev_name(phydev), phydev->irq);

It could be nice to expose the format string here along with parameters
to let drivers decide how much additional information they want to print
rather than forcing this to the core PHY library. Maybe something ala
phy_print_status() which takes variadic arguments?

Some drivers also seem to have a netif_msg_probe() conditional to guard
this print, I am not sure if we should keep that, probably not.
-- 
Florian
