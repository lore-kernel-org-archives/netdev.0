From: Trent Piepho <tpiepho@freescale.com>
Subject: Re: [PATCHv3 5/5] [NET] dsa: add support for the Marvell 88E6060
 switch chip
Date: Tue, 7 Oct 2008 17:45:41 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0810071725300.4731@k.domain.actdsltmp>
References: <20081007234622.GF23200@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:45070 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756932AbYJHAqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 20:46:15 -0400
In-Reply-To: <20081007234622.GF23200@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Oct 2008, Lennert Buytenhek wrote:
> +
> +static int reg_read(struct dsa_switch *ds, int addr, int reg)
> +{
> +	return mdiobus_read(ds->master_mii_bus, addr, reg);
> +}

Instead of all the code to add the mdio buses to the device tree and exporting
mdiobus_read(), could you have just added the switch chip as a "phy" on the
mdio bus?  Then used phy_read/write() on it?  I know it's not a phy, but you
don't need to use the phy state machine and so on.

Freescale gianfar MACs configure the serdes for SGMII using a virtual "TBI"
device on the MDIO bus.  Supposedly Andy has patch that adds them as devices
on the MDIO bus, isn't of the gianfar specific MDIO back-door they currently
use.

> +#define REG_READ(addr, reg)					\
> +	({							\
> +		int __ret;					\
> +								\
> +		__ret = reg_read(ds, addr, reg);		\
> +		if (__ret < 0)					\
> +			return __ret;				\
> +		__ret;						\
> +	})

Macro with a hidden use of a local ('ds') and a hidden return?  The former is
discouraged (but can sure save a lot of typing) but the latter seems like it's
just begging to cause a missing unlock or free on an error path.
