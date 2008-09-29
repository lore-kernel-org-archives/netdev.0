From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH 3/3] phylib: give mdio buses a device tree presence
Date: Mon, 29 Sep 2008 17:45:01 -0500
Message-ID: <425FFC3E-EAE1-4BE3-89CD-9A6363BBAFA7@freescale.com>
References: <20080929021400.GE21560@xi.wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:46296 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751596AbYI2Wpr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 18:45:47 -0400
In-Reply-To: <20080929021400.GE21560@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 28, 2008, at 21:14, Lennert Buytenhek wrote:

> Introduce the mdio_bus class, and give each 'struct mii_bus' its own
> 'struct device', so that mii_bus objects are represented in the device
> tree and can be found by querying the device tree.
>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> ---
> drivers/net/phy/mdio_bus.c |   74 +++++++++++++++++++++++++++++++++++ 
> ++++++--
> include/linux/phy.h        |    8 +++++
> 2 files changed, 78 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index d206691..f9c27ac 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -43,11 +43,35 @@
>  */
> struct mii_bus *mdiobus_alloc(void)
> {
> -	return kzalloc(sizeof(struct mii_bus), GFP_KERNEL);
> +	struct mii_bus *bus;
> +
> +	bus = kzalloc(sizeof(*bus), GFP_KERNEL);
> +	if (bus != NULL)
> +		bus->state = MDIOBUS_ALLOCATED;
> +
> +	return bus;
> }
> EXPORT_SYMBOL(mdiobus_alloc);


Do we really need all this state tracking?  Doesn't the device layer  
do this for us?  I looked through other driver subsystems, and I  
didn't see anything like this.  Can we rearchitect this so that we're  
not having to track allocation/registration state?

Andy
