From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH] [v8] net: emac: emac gigabit ethernet controller driver
Date: Wed, 17 Aug 2016 22:05:51 +0200
Message-ID: <20160817200551.GA24842@lunn.ch>
References: <1470951245-13665-1-git-send-email-timur@codeaurora.org>
 <db618958-a940-9ea2-ff52-e12c81894ad6@gmail.com>
 <57B4BD40.1070703@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57B4BD40.1070703-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Something is odd about of_mdiobus_register().
> 
> This function scans child nodes to look for PHYs:
> 
> /* Loop over the child nodes and register a phy_device for each phy */
> for_each_available_child_of_node(np, child) {
> 	addr = of_mdio_parse_addr(&mdio->dev, child);
> 
> And in my driver, this works.  However, later when I try to call
> of_phy_find_device(), it fails.  That's because of_phy_find_device()
> wants the np of the child node.  But the only way to get that is
> with a phy-phandle property which I need to manually parse.

You do need the phy-handle, because you can have multiple PHYs, and
ethernet switches on the MDIO bus. You need to indicate which of those
PHYs is connected to this MAC.

> So what's the point of having of_mdiobus_register() parse child
> nodes, if you need a phy-phandle pointer anyway?

So we know about the other phys and switches on the MDIO bus, can load
the driver for them, etc. This is standard policy for a bus
driver. When you instantiate the bus, you enumerate it to see what is
connected to it. You do that either with of_mdiobus_register() or
mdiobus_register().

However, i do agree about having a helper do the phy-handle parsing
would be nice, and it should also handle fixed phys as well.

      Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
