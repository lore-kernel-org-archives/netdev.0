From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/6] phylib: add mdiobus_{read,write}
Date: Mon, 29 Sep 2008 23:10:09 +0200
Message-ID: <20080929211009.GD31038@xi.wantstofly.org>
References: <20080929023748.GG21560@xi.wantstofly.org> <Pine.LNX.4.64.0809291325460.7680@t2.domain.actdsltmp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Byron Bradley <byron.bbradley@gmail.com>,
	Jesper Dangaard Brouer <jdb@comx.dk>,
	Tim Ellis <tim.ellis@mac.com>,
	Andy Fleming <afleming@freescale.com>,
	Imre Kaloz <kaloz@openwrt.org>, Nicolas Pitre <nico@cam.org>,
	Dirk Teurlings <dirk@upexia.nl>,
	Peter van Valderen <p.v.valderen@gmail.com>
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:40431 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751464AbYI2VKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2008 17:10:12 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0809291325460.7680@t2.domain.actdsltmp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 29, 2008 at 01:27:11PM -0700, Trent Piepho wrote:

> > Add mdiobus_{read,write} routines to allow direct reading/writing
> > of registers on an mii bus without having to go through the PHY
> > abstraction, and make phy_{read,write} use these primitives.
> >
> > int phy_read(struct phy_device *phydev, u16 regnum)
> > {
> > -	int retval;
> > -	struct mii_bus *bus = phydev->bus;
> > -
> > -	BUG_ON(in_interrupt());
> > -
> > -	mutex_lock(&bus->mdio_lock);
> > -	retval = bus->read(bus, phydev->addr, regnum);
> > -	mutex_unlock(&bus->mdio_lock);
> > -
> > -	return retval;
> > +	return mdiobus_read(phydev->bus, phydev->addr, regnum);
> > }
> > EXPORT_SYMBOL(phy_read);
> 
> Might want to make these function static inline.  Since they are
> external, gcc won't be able to inline them automatically.

If i make them static inline, I won't be able to call them from
external code, which was sort of the idea.

Or are you suggesting that I move them to include/linux/phy.h ?
