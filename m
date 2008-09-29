From: Andy Fleming <afleming@freescale.com>
Subject: Re: [PATCH 1/6] phylib: add mdiobus_{read,write}
Date: Mon, 29 Sep 2008 18:30:28 -0500
Message-ID: <AA75D6CD-4BEA-4189-AFA9-4111D77804B9@freescale.com>
References: <20080929023748.GG21560@xi.wantstofly.org>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>, Imre Kaloz <kaloz@openwrt.org>,
	Nicolas Pitre <nico@cam.org>, Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:60318 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbYI2Xby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 19:31:54 -0400
In-Reply-To: <20080929023748.GG21560@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 28, 2008, at 21:37, Lennert Buytenhek wrote:

> Add mdiobus_{read,write} routines to allow direct reading/writing
> of registers on an mii bus without having to go through the PHY
> abstraction, and make phy_{read,write} use these primitives.
>
> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Looks pretty good.  I was actually just thinking this might be handy  
for some code we're working on.

Just one comment...

>
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -68,16 +68,7 @@ EXPORT_SYMBOL(phy_print_status);
>  */
> int phy_read(struct phy_device *phydev, u16 regnum)
> {
> -	int retval;
> -	struct mii_bus *bus = phydev->bus;
> -
> -	BUG_ON(in_interrupt());
> -
> -	mutex_lock(&bus->mdio_lock);
> -	retval = bus->read(bus, phydev->addr, regnum);
> -	mutex_unlock(&bus->mdio_lock);
> -
> -	return retval;
> +	return mdiobus_read(phydev->bus, phydev->addr, regnum);
> }
> EXPORT_SYMBOL(phy_read);


I agree with Trent.  Move these into phy.h and make them static inline


