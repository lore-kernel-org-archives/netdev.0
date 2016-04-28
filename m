From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] net: macb: do not scan PHYs manually
Date: Thu, 28 Apr 2016 20:59:32 +0200
Message-ID: <20160428185932.GU29024@lunn.ch>
References: <1461854802-8142-1-git-send-email-nathan.sullivan@ni.com>
 <57222FCE.8050407@atmel.com>
 <20160428155556.GA8333@nathan3500-linux-VM>
 <20160428163207.GP29024@lunn.ch>
 <20160428175619.GA8791@nathan3500-linux-VM>
 <20160428184303.GR29024@lunn.ch>
 <20160428185527.GA8851@nathan3500-linux-VM>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Florian Fainelli <f.fainelli@gmail.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>
To: Nathan Sullivan <nathan.sullivan@ni.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160428185527.GA8851@nathan3500-linux-VM>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 28, 2016 at 01:55:27PM -0500, Nathan Sullivan wrote:
> On Thu, Apr 28, 2016 at 08:43:03PM +0200, Andrew Lunn wrote:
> > > I agree that is a valid fix for AT91, however it won't solve our problem, since
> > > we have no children on the second ethernet MAC in our devices' device trees. I'm
> > > starting to feel like our second MAC shouldn't even really register the MDIO bus
> > > since it isn't being used - maybe adding a DT property to not have a bus is a
> > > better option?
> > 
> > status = "disabled"
> > 
> > would be the unusual way.
> > 
> >       Andrew
> 
> Oh, sorry, I meant we use both MACs on Zynq, however the PHYs are on the MDIO
> bus of the first MAC.  So, the second MAC is used for ethernet but not for MDIO,
> and so it does not have any PHYs under its DT node.  It would be nice if there
> were a way to tell macb not to bother with MDIO for the second MAC, since that's
> handled by the first MAC.

Yes, exactly, add support for status = "disabled" in the mdio node.

> I guess a good longer-term solution to all these problems would be to treat the
> MAC and MDIO as seperate devices, like davinci seems to be doing.

A few others do this as well, e.g. most Marvell devices.

  Andrew
