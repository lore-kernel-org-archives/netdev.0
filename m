From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Thu, 28 Apr 2016 22:10:50 +0200
Message-ID: <20160428201050.GC13547@lunn.ch>
References: <1461854802-8142-1-git-send-email-nathan.sullivan@ni.com>
 <57222FCE.8050407@atmel.com>
 <20160428155556.GA8333@nathan3500-linux-VM>
 <20160428163207.GP29024@lunn.ch>
 <20160428175619.GA8791@nathan3500-linux-VM>
 <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM>
 <20160428185932.GU29024@lunn.ch>
 <57226C83.8040509@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nathan Sullivan <nathan.sullivan@ni.com>,
	Nicolas Ferre <nicolas.ferre@atmel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52338 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752804AbcD1UK4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 16:10:56 -0400
Content-Disposition: inline
In-Reply-To: <57226C83.8040509@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 01:03:15PM -0700, Florian Fainelli wrote:
> On 28/04/16 11:59, Andrew Lunn wrote:
> > On Thu, Apr 28, 2016 at 01:55:27PM -0500, Nathan Sullivan wrote:
> >> On Thu, Apr 28, 2016 at 08:43:03PM +0200, Andrew Lunn wrote:
> >>>> I agree that is a valid fix for AT91, however it won't solve our problem, since
> >>>> we have no children on the second ethernet MAC in our devices' device trees. I'm
> >>>> starting to feel like our second MAC shouldn't even really register the MDIO bus
> >>>> since it isn't being used - maybe adding a DT property to not have a bus is a
> >>>> better option?
> >>>
> >>> status = "disabled"
> >>>
> >>> would be the unusual way.
> >>>
> >>>       Andrew
> >>
> >> Oh, sorry, I meant we use both MACs on Zynq, however the PHYs are on the MDIO
> >> bus of the first MAC.  So, the second MAC is used for ethernet but not for MDIO,
> >> and so it does not have any PHYs under its DT node.  It would be nice if there
> >> were a way to tell macb not to bother with MDIO for the second MAC, since that's
> >> handled by the first MAC.
> > 
> > Yes, exactly, add support for status = "disabled" in the mdio node.
> 
> Something like that, just so we do not have to sprinkle tests all other
> the place:
> 
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index b622b33dbf93..2f497790be1b 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -209,6 +209,10 @@ int of_mdiobus_register(struct mii_bus *mdio,
> struct device_node *np)
>         bool scanphys = false;
>         int addr, rc;
> 
> +       /* Do not continue if the node is disabled */
> +       if (!of_device_is_available(np))
> +               return -EINVAL;
> +
>         /* Mask out all PHYs from auto probing.  Instead the PHYs listed in
>          * the device tree are populated after the bus has been
> registered */
>         mdio->phy_mask = ~0;

Yes, that looks good.

     Andrew
