From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY address when
 connecting to the PHY
Date: Fri, 28 Jul 2017 06:21:53 +0200
Message-ID: <20170728042153.GH18666@lunn.ch>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-4-antoine.tenart@free-electrons.com>
 <20170726160806.GF12049@lunn.ch>
 <20170728014905.GC24728@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jason@lakedaemon.net,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        linux@armlinux.org.uk, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43354 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750935AbdG1EWF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Jul 2017 00:22:05 -0400
Content-Disposition: inline
In-Reply-To: <20170728014905.GC24728@kwain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 27, 2017 at 06:49:05PM -0700, Antoine Tenart wrote:
> Hi Andrew,
> 
> On Wed, Jul 26, 2017 at 06:08:06PM +0200, Andrew Lunn wrote:
> > On Mon, Jul 24, 2017 at 03:48:33PM +0200, Antoine Tenart wrote:
> > >  
> > > +	if (priv->hw_version != MVPP22)
> > > +		return 0;
> > > +
> > > +	/* Set the SMI PHY address */
> > > +	if (of_property_read_u32(port->phy_node, "reg", &phy_addr)) {
> > > +		netdev_err(port->dev, "cannot find the PHY address\n");
> > > +		return -EINVAL;
> > > +	}
> > > +
> > > +	writel(phy_addr, priv->iface_base + MVPP22_SMI_PHY_ADDR(port->gop_id));
> > >  	return 0;
> > >  }
> > 
> > You could use phy_dev->mdiodev->addr, rather than parse the DT.
> 
> OK.
> 
> > Why does the MAC need to know this address? The phylib and PHY driver
> > should be the only thing accessing the PHY, otherwise you are asking
> > for trouble.
> 
> This is part of the SMI/xSMI interface. I added into the mvpp2 driver
> and not in the mvmdio one because the GoP port number must be known to
> set this register (so that would be even less clean to do it).

Hi Antoine

It is still not clear to my why you need to program the address into
the hardware. Is the hardware talking to the PHY?

    Andrew
