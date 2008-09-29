From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: [PATCH 1/6] phylib: add mdiobus_{read,write}
Date: Mon, 29 Sep 2008 13:27:11 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0809291325460.7680@t2.domain.actdsltmp>
References: <20080929023748.GG21560@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>,
	Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>, Nicolas Pitre <nico@cam.org>,
	Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:61578 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752021AbYI2UeS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 16:34:18 -0400
In-Reply-To: <20080929023748.GG21560@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Sep 2008, Lennert Buytenhek wrote:
> Add mdiobus_{read,write} routines to allow direct reading/writing
> of registers on an mii bus without having to go through the PHY
> abstraction, and make phy_{read,write} use these primitives.
>
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

Might want to make these function static inline.  Since they are external, gcc
won't be able to inline them automatically.
