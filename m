From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH 0/2] net: macb: Add mdio driver for accessing
 multiple phy devices
Date: Mon, 20 Jul 2015 18:23:53 +0200
Message-ID: <20150720162353.GF14842@lunn.ch>
References: <1436762920-32107-1-git-send-email-punnaia@xilinx.com>
 <55ACF7FC.4020408@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Punnaiah Choudary Kalluri <punnaiah.choudary.kalluri@xilinx.com>,
	nicolas.ferre@atmel.com, anirudh@xilinx.com, davem@davemloft.net,
	harinik@xilinx.com, kpc528@gmail.com,
	kalluripunnaiahchoudary@gmail.com, netdev@vger.kernel.org,
	Punnaiah Choudary Kalluri <punnaia@xilinx.com>
To: Michal Simek <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44359 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932220AbbGTQac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Jul 2015 12:30:32 -0400
Content-Disposition: inline
In-Reply-To: <55ACF7FC.4020408@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 20, 2015 at 03:30:36PM +0200, Michal Simek wrote:
> Hi Nicolas,
> 
> have you had a time to look at this?
> 
> Thanks,
> Michal
> 
> On 07/13/2015 06:48 AM, Punnaiah Choudary Kalluri wrote:
> > This patch is to add support for the design that has multiple ethernet
> > mac controllers and single mdio bus connected to multiple phy devices.
> > i.e mdio lines are connected to any of the ethernet mac controller and
> > all the phy devices will be accessed using the phy maintenance interface
> > in that mac controller.
> > 
> >  ______                   _____
> > |      |                 |PHY0 |
> > | MAC0 |-----------------|     |
> > |______|       |         |_____|
> >                |           
> >  ______        |          _____
> > |      |       |         |     |
> > | MAC1 |       |_________|PHY1 | 
> > |______|                 |____ |
> > 
> > So, i come up with two implementations for addressing the above configuration.
> > 
> > Implementation 1:
> >  Have separate driver for mdio bus
> >  Create a DT node for all the PHY devices connected to the mdio bus
> >  This driver will share the register space of the mac controller that has
> >  mdio bus connected.  
> > 

Hi Michal

The above it what Marvell, Freescale FEC and probably others do. It is
well defined in Documentation/devicetree/bindings/net/ethernet.txt
that you can have a phy-handle property containing a phandle to the
actual phy device on some random MDIO bus.

     Andrew
