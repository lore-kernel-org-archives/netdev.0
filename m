From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Fri, 29 Apr 2016 14:56:22 +0200
Message-ID: <20160429125622.GE4053@lunn.ch>
References: <20160428163207.GP29024@lunn.ch>
 <20160428175619.GA8791@nathan3500-linux-VM>
 <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM>
 <20160428185932.GU29024@lunn.ch>
 <20160428210357.GB30217@jcartwri.amer.corp.natinst.com>
 <20160428212315.GC12753@lunn.ch>
 <20160429003459.GC30217@jcartwri.amer.corp.natinst.com>
 <20160429122501.GD30217@jcartwri.amer.corp.natinst.com>
 <57235655.3030104@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Cartwright <joshc@ni.com>,
	Nathan Sullivan <nathan.sullivan@ni.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57235655.3030104@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > +static int macb_mii_of_init(struct macb *bp, struct device_node *np)
> > +{
> > +	struct device_node *mdio;
> > +	int err, i;
> > +
> > +	mdio = of_get_child_by_name(np, "mdio");
> > +	if (mdio)
> > +		return of_mdiobus_register(bp->mii_bus, mdio);
> > +
> > +	dev_warn(&bp->pdev->dev,
> > +		 "using deprecated PHY probing mechanism.  Please update device tree.");
> 
> Do we need to warn here?
> 
> Too bad I was not aware of that earlier, I even updated some of my DTs
> recently with only a phy node without the "mdio" one as parents :-\

It is messy. Unfortunately, there is no binding documentation (yet)
suggesting the right way to do this. And as a result, we have
drivers/device trees doing different things, leading to workarounds
like manually scanning the bus, not listing PHYs in the device tree
and so or falling back to the old methods, etc.

We need to document how we expect this to be done, and then add
warnings in various places to encourage developers to migrate their
device trees to what has been documented.

       Andrew
