From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 7/7] net: dsa: bcm_sf2: Register our slave MDIO
 bus
Date: Sat, 4 Jun 2016 22:49:37 +0200
Message-ID: <20160604204937.GI2063@lunn.ch>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-12-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59656 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751021AbcFDUtk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 16:49:40 -0400
Content-Disposition: inline
In-Reply-To: <1464998733-10405-12-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -static int bcm_sf2_sw_phy_read(struct dsa_switch *ds, int addr, int regnum)
> +static int bcm_sf2_sw_phy_read(struct mii_bus *bus, int addr, int regnum)

Hi Florian

When i did the same for mv88e6xxx, i renamed _phy_ to _mdio_. That
keeps with the general pattern for other mdio drivers, making it clear
there can be something else than a phy on the bus.

> +	priv->slave_mii_bus->priv = priv;
> +	priv->slave_mii_bus->name = "sf2 slave mii";

> +	if (dn)
> +		snprintf(priv->slave_mii_bus->id, MII_BUS_ID_SIZE, "%s",
> +			 ds->dev->of_node->full_name);

I tried lots of different things with mv88e6xxx, including i think
this. The problem is full_name can be quite long, so it gets
truncated. And i often found two different mv88e6xxx ended up with
identical truncated names, since the unique part was getting
discarded.

> +	else
> +		snprintf(priv->slave_mii_bus->id, MII_BUS_ID_SIZE, "sf2-%d",
> +			 index++);

So i ended up with this, which is 100% reliable. 

   Andrew
