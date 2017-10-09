From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next] net: mvpp2: phylink support
Date: Mon, 9 Oct 2017 14:55:27 +0200
Message-ID: <20171009125527.GA24414@kwain>
References: <20170921134522.10993-1-antoine.tenart@free-electrons.com>
 <20170922110731.GG20805@n2100.armlinux.org.uk>
 <20170925095514.GA19364@kwain>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        thomas.petazzoni@free-electrons.com,
        miquel.raynal@free-electrons.com, nadavh@marvell.com,
        linux-kernel@vger.kernel.org, mw@semihalf.com, stefanc@marvell.com,
        netdev@vger.kernel.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170925095514.GA19364@kwain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Russell,

On Mon, Sep 25, 2017 at 11:55:14AM +0200, Antoine Tenart wrote:
> On Fri, Sep 22, 2017 at 12:07:31PM +0100, Russell King - ARM Linux wrote:
> > On Thu, Sep 21, 2017 at 03:45:22PM +0200, Antoine Tenart wrote:
> 
> > > +static int mvpp2_phylink_mac_link_state(struct net_device *dev,
> > > +					struct phylink_link_state *state)
> > > +{
> > > +	struct mvpp2_port *port = netdev_priv(dev);
> > > +	u32 val;
> > > +
> > > +	if (!phy_interface_mode_is_rgmii(port->phy_interface) &&
> > > +	    port->phy_interface != PHY_INTERFACE_MODE_SGMII)
> > > +		return 0;
> > 
> > You're blocking this for 1000base-X and 10G connections, which is not
> > correct.  The expectation is that this function returns the current
> > MAC state irrespective of the interface mode.
> 
> I moved what was already supported in the PPv2 driver and did not
> implemented the full set of what is supported. It's not perfect, but it
> does move what was already supported.
> 
> Any reason not to first move what's already supported to phylink, and
> then add more supported modes in separate patches?

Any thoughts on this?

> > > +static void mvpp2_mac_config(struct net_device *dev, unsigned int mode,
> > > +			     const struct phylink_link_state *state)
> > > +{
> > > +	struct mvpp2_port *port = netdev_priv(dev);
> > > +	u32 val;
> > > +
> > > +	/* disable current port for reconfiguration */
> > > +	mvpp2_interrupts_disable(port);
> > > +	netif_carrier_off(port->dev);
> > > +	mvpp2_port_disable(port);
> > > +	phy_power_off(port->comphy);
> > > +
> > > +	/* comphy reconfiguration */
> > > +	port->phy_interface = state->interface;
> > > +	mvpp22_comphy_init(port);
> > > +
> > > +	/* gop/mac reconfiguration */
> > > +	mvpp22_gop_init(port);
> > > +	mvpp2_port_mii_set(port);
> > > +
> > > +	if (!phy_interface_mode_is_rgmii(port->phy_interface) &&
> > > +	    port->phy_interface != PHY_INTERFACE_MODE_SGMII)
> > > +		return;
> > 
> > Again, 1000base-X is excluded, which will break it.  You do need
> > to avoid touching the GMAC for 10G connections however.
> 
> Same comment as above.

Antoine

-- 
Antoine Ténart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com
