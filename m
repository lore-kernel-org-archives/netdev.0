From: Russell King - ARM Linux <linux@armlinux.org.uk>
Subject: Re: [PATCH net-next] net: mvpp2: phylink support
Date: Mon, 9 Oct 2017 14:09:24 +0100
Message-ID: <20171009130924.GS20805@n2100.armlinux.org.uk>
References: <20170921134522.10993-1-antoine.tenart@free-electrons.com>
 <20170922110731.GG20805@n2100.armlinux.org.uk>
 <20170925095514.GA19364@kwain>
 <20171009125527.GA24414@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: Antoine Tenart <antoine.tenart@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171009125527.GA24414@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 09, 2017 at 02:55:27PM +0200, Antoine Tenart wrote:
> Hi Russell,
> 
> On Mon, Sep 25, 2017 at 11:55:14AM +0200, Antoine Tenart wrote:
> > On Fri, Sep 22, 2017 at 12:07:31PM +0100, Russell King - ARM Linux wrote:
> > > On Thu, Sep 21, 2017 at 03:45:22PM +0200, Antoine Tenart wrote:
> > 
> > > > +static int mvpp2_phylink_mac_link_state(struct net_device *dev,
> > > > +					struct phylink_link_state *state)
> > > > +{
> > > > +	struct mvpp2_port *port = netdev_priv(dev);
> > > > +	u32 val;
> > > > +
> > > > +	if (!phy_interface_mode_is_rgmii(port->phy_interface) &&
> > > > +	    port->phy_interface != PHY_INTERFACE_MODE_SGMII)
> > > > +		return 0;
> > > 
> > > You're blocking this for 1000base-X and 10G connections, which is not
> > > correct.  The expectation is that this function returns the current
> > > MAC state irrespective of the interface mode.
> > 
> > I moved what was already supported in the PPv2 driver and did not
> > implemented the full set of what is supported. It's not perfect, but it
> > does move what was already supported.
> > 
> > Any reason not to first move what's already supported to phylink, and
> > then add more supported modes in separate patches?
> 
> Any thoughts on this?

You're asking me to comment about something I know little about as
I've not used mvpp2.c.  I don't know the details of what your "already
supported" statement refers to.  Maybe you could give some clues -
maybe produce a list of what mvpp2 currently supports?

Here's the link modes that phylink supports:
1. PHY based links
2. PHYless fixed links with details specified in DT, in the same way as
   the existing "fixed-link" support works, but without needing to create
   fake PHYs.
3. PHYless fixed links with GPIO link indication (again, same way as the
   existing fixed-link support.)
4. Direct fibre connections via fixed-link or SFP.

-- 
RMK's Patch system: http://www.armlinux.org.uk/developer/patches/
FTTC broadband for 0.8mile line in suburbia: sync at 8.8Mbps down 630kbps up
According to speedtest.net: 8.21Mbps down 510kbps up
