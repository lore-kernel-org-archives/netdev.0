From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 3/6 v2] au1000-eth: fix all "line over 80 characters
 warnings"
Date: Thu, 12 Aug 2010 07:48:50 -0700
Message-ID: <1281624530.15486.33.camel@Joe-Laptop>
References: <201008121009.59133.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1029 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751226Ab0HLOsw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 10:48:52 -0400
In-Reply-To: <201008121009.59133.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-08-12 at 10:09 +0200, Florian Fainelli wrote:
> --- a/drivers/net/au1000_eth.c
> +++ b/drivers/net/au1000_eth.c
> @@ -377,12 +377,15 @@ static int au1000_mii_probe(struct net_device *dev)
> -		for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++)
> +		/* find the first (lowest address) PHY
> +		 * on the current MAC's MII bus */
> +		for (phy_addr = 0;
> +			phy_addr < PHY_MAX_ADDR; phy_addr++)

Breaking up the for is not an improvement, it's already < 80

> @ -390,22 +393,26 @@ static int au1000_mii_probe(struct net_device *dev)
>  			if (!phydev && (aup->mac_id == 1)) {
>  				/* no PHY found, maybe we have a dual PHY? */
>  				dev_info(&dev->dev, ": no PHY found on MAC1, "
> -					"let's see if it's attached to MAC0...\n");
> +					"let's see if it's attached to MAC0..."
> +					"\n");

Definitely not an improvement.

>  
> -				/* find the first (lowest address) non-attached PHY on
> -				 * the MAC0 MII bus */
> -				for (phy_addr = 0; phy_addr < PHY_MAX_ADDR; phy_addr++) {
> +				/* find the first (lowest address) non-attached
> +				 * PHY on the MAC0 MII bus */
> +				for (phy_addr = 0; phy_addr < PHY_MAX_ADDR;
> +								phy_addr++) {
>  					struct phy_device *const tmp_phydev =
> -							aup->mii_bus->phy_map[phy_addr];
> +						aup->mii_bus->phy_map[phy_addr];
>  
>  					if (aup->mac_id == 1)
>  						break;

Can you find a way to reduce the indentation level instead?

> @@ -709,7 +719,8 @@ static int au1000_rx(struct net_device *dev)
>  			frmlen -= 4; /* Remove FCS */
>  			skb = dev_alloc_skb(frmlen + 2);
>  			if (skb == NULL) {
> -				netdev_err(dev, "Memory squeeze, dropping packet.\n");
> +				netdev_err(dev, "Memory squeeze,"
> +							" dropping packet.\n");

Not an improvement. etc...

> +	netif_dbg(aup, drv, dev, "au1000_multicast_list: flags=%x\n",
> +							dev->flags);
[]
> +		dev_err(&pdev->dev, "failed to request memory region for"
> +						" base registers\n");
[]
> +		dev_err(&pdev->dev, "failed to request memory region for"
> +						" MAC enable register\n");
[]
>  		dev_err(&pdev->dev, "MAC0-associated PHY attached 2nd MACs MII"
> -				"bus not supported yet\n");
> +				" bus not supported yet\n");


