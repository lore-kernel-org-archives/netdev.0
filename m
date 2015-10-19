From: Dinh Nguyen <dinguyen@opensource.altera.com>
Subject: Re: SoCFPGA ethernet broken
Date: Mon, 19 Oct 2015 10:14:21 -0500
Message-ID: <alpine.DEB.2.02.1510190521370.27515@linux-builds1>
References: <56201158.8040806@opensource.altera.com> <56201AE7.2020103@gmail.com> <alpine.DEB.2.02.1510152102280.22844@linux-builds1> <20151016033143.GA28207@lunn.ch> <alpine.DEB.2.02.1510160935310.22648@linux-builds1> <20151016150345.GI10146@lunn.ch>
 <alpine.DEB.2.02.1510161027590.16637@linux-builds1> <20151016155644.GJ10146@lunn.ch> <56212A09.5080206@caviumnetworks.com> <alpine.DEB.2.02.1510161407570.22838@linux-builds1> <20151016193854.GC28207@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Daney <ddaney@caviumnetworks.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, <david.daney@cavium.com>,
	<peppe.cavallaro@st.com>, <srinivas.kandagatla@gmail.com>,
	<maxime.coquelin@st.com>, <patrice.chotard@st.com>,
	<heiko@sntech.de>, <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151016193854.GC28207@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

+CC Giuseppe Cavallaro
+CC STi and Rockchip Maintainers

This is approaching beyond my breadth of knowledge on this subject, so I just
wanted to get some further insight.

On Fri, 16 Oct 2015, Andrew Lunn wrote:

> > > Maybe we need to walk up the hierarchy.
> > > 
> > > Perhaps something like:
> > > 
> > > const struct device *dev_walker;
> > > 
> > > dev_walker = &phydev->dev;
> > > do {
> > >    of_node = dev_walker->of_node;
> > >    dev_walker = dev_walker->parent;
> > > } while (!of_node && dev_walker);
> > > 
> > 
> > The above code seems to have fixed the issue.
> 
> What i don't like about this is that it allows you to put these
> properties in the mdio device node. These are phy properties, not mdio
> properties....
>

AFAICT, the stmmac driver is allowing for the phy node to be part of the mdio.
In the function, stmmac_init_phy(), there is a separate check of a standalone
phy_node, and the case where the phy is part of the mdio.

commit "8b63ec1837fa phylib: Make PHYs children of their MDIO bus, not
the bus' parent." is now placing a hard requirement to have a PHY as a
separate node. For now this is only breaking SoCFPGA, but perhaps might
have affected STi41x and RockChip, but maybe haven't been spotted because
perhaps the testing has the bootloader setting up the PHYs?

> If phydev->attached_dev->dev->of_node works, that would be my
> preference.
>

BR,
Dinh
