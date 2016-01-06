From: Shaohui Xie <shaohui.xie@nxp.com>
Subject: RE: [RFC PATCH net-next 10/24] mdio: Move allocation of interrupts
 into core
Date: Wed, 6 Jan 2016 14:07:31 +0000
Message-ID: <VI1PR04MB1664C211E5C7BD0BCDA1DF6AE8F40@VI1PR04MB1664.eurprd04.prod.outlook.com>
References: <1451929022-5580-1-git-send-email-andrew@lunn.ch>
 <1451929022-5580-11-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0072.outbound.protection.outlook.com ([157.56.112.72]:37696
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751777AbcAFOk3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 09:40:29 -0500
In-Reply-To: <1451929022-5580-11-git-send-email-andrew@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Have mdio_alloc() create the array of interrupt numbers, and
> initialize it to POLLING. This is what most MDIO drivers want, so
> allowing code to be removed from the drivers.
> 
[S.H] Snip.

> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 88cb4592b6fb..05381d0f559c 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -51,6 +51,7 @@ struct mii_bus *mdiobus_alloc_size(size_t size)
>  	struct mii_bus *bus;
>  	size_t aligned_size = ALIGN(sizeof(*bus), NETDEV_ALIGN);
>  	size_t alloc_size;
> +	int i;
> 
>  	/* If we alloc extra space, it should be aligned */
>  	if (size)
> @@ -65,6 +66,10 @@ struct mii_bus *mdiobus_alloc_size(size_t size)
>  			bus->priv = (void *)bus + aligned_size;
>  	}
> 
> +	/* Initialise the interrupts to polling */
> +	for (i = 0; i < PHY_MAX_ADDR; i++)
> +		bus->irq[i] = PHY_POLL;
> +
>  	return bus;
>  }
[S.H] Should similar code in of_mdiobus_register() to remove?

Thanks,

Shaohui
