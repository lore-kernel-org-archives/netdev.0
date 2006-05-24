From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [patch 1/2] spidernet: enable support for bcm5461 ethernet phy
Date: Wed, 24 May 2006 01:29:24 -0400
Message-ID: <4473EF34.7050007@pobox.com>
References: <20060504155034.486042000@> <200605041159.41470.Jens.Osterkamp@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, arndb@de.ibm.com, utz.bacher@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:4832 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932516AbWEXF3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 01:29:30 -0400
To: Jens.Osterkamp@de.ibm.com
In-Reply-To: <200605041159.41470.Jens.Osterkamp@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jens Osterkamp wrote:
> From: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
> 
> A newer board revision changed the type of ethernet phy.
> Moreover, this generalizes the way that a phy gets switched
> into fiber mode when autodetection is not available.
> 
> Signed-off-by: Jens Osterkamp <Jens.Osterkamp@de.ibm.com>
> Signed-off-by: Arnd Bergmann <arnd.bergmann@de.ibm.com>
> 
> ---
> Index: linus-2.6/drivers/net/sungem_phy.c
> ===================================================================
> --- linus-2.6.orig/drivers/net/sungem_phy.c
> +++ linus-2.6/drivers/net/sungem_phy.c
> @@ -329,6 +329,30 @@ static int bcm5421_init(struct mii_phy* 
>  	return 0;
>  }
>  
> +static int bcm5421_enable_fiber(struct mii_phy* phy)
> +{
> +	/* enable fiber mode */
> +	phy_write(phy, MII_NCONFIG, 0x9020);
> +	/* LEDs active in both modes, autosense prio = fiber */
> +	phy_write(phy, MII_NCONFIG, 0x945f);
> +
> +	/* switch off fibre autoneg */
> +	phy_write(phy, MII_NCONFIG, 0xfc01);
> +	phy_write(phy, 0x0b, 0x0004);
> +
> +	return 0;
> +}
> +
> +static int bcm5461_enable_fiber(struct mii_phy* phy)
> +{
> +        phy_write(phy, MII_NCONFIG, 0xfc0c);
> +        phy_write(phy, MII_BMCR, 0x4140);
> +        phy_write(phy, MII_NCONFIG, 0xfc0b);
> +	phy_write(phy, MII_BMCR, 0x0140);

NAK, failed to apply.  Also, the whitespace above is borked.

	Jeff



