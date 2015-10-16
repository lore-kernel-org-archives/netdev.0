From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: SoCFPGA ethernet broken
Date: Fri, 16 Oct 2015 17:03:45 +0200
Message-ID: <20151016150345.GI10146@lunn.ch>
References: <561FF9E2.30102@opensource.altera.com>
 <56200687.9040903@gmail.com>
 <562005AD.8020903@opensource.altera.com>
 <56200BD7.8020505@gmail.com>
 <56200E15.9080603@caviumnetworks.com>
 <56201158.8040806@opensource.altera.com>
 <56201AE7.2020103@gmail.com>
 <alpine.DEB.2.02.1510152102280.22844@linux-builds1>
 <20151016033143.GA28207@lunn.ch>
 <alpine.DEB.2.02.1510160935310.22648@linux-builds1>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	David Daney <ddaney@caviumnetworks.com>,
	"David S. Miller" <davem@davemloft.net>, david.daney@cavium.com,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Dinh Nguyen <dinguyen@opensource.altera.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1510160935310.22648@linux-builds1>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 16, 2015 at 09:38:37AM -0500, Dinh Nguyen wrote:
> On Fri, 16 Oct 2015, Andrew Lunn wrote:
> 
> > > Another debugging point, the SoCFPGA board has a Micrel ksz9021 PHY attached
> > > to the ethernet port. What I'm seeing is that with 8b63ec1837fa patch, when
> > > the call to ksz9021_config_init() is made both of_node and dev->parent->of_node
> > > are NULL, without the patch the dev->parent->of_node is a valid pointer. Thus
> > > the skew values get programmed to the phy.
> > 
> > Ah!
> > 
> > You have the phy device tree parameters in the wrong place. These are
> > phy paramters, so should really be in the phy node. But
> > socfpga_cyclone5_socdk.dts has them in the MAC node.
> >
> 
> Alright, let me see if I can rework the DTS.

Well, we are not supposed to break device tree bindings. So we should
try to make this work again.
  
> > There is nothing in Documentation/devicetree/bindings/net/micrel.txt
> > which says you are allowed to place them in the MAC node. Obviously
> > the code did allow this, which is what has now broken.
> 
> I was following Documentation/devicetree/bindings/net/micrel-ksz90x1.txt and
> in this document I was following the autodetected PHY example. Did I mis-interpret
> the example?

I was looking at the wrong binding documentation. So yes, it is
documented you can do this.

But i still think it is wrong. These are phy properties, implemented
by the phy, so should be in the phy node. So moving them would be
good. But as i said, we should fix backwards compatibility if
possible.

	Andrew
