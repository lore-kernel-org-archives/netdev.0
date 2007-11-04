From: Olof Johansson <olof@lixom.net>
Subject: Re: [PATCH] net: Add 405EX support to new EMAC driver
Date: Sun, 4 Nov 2007 11:16:45 -0600
Message-ID: <20071104171645.GA10191@lixom.net>
References: <200711020814.43524.sr@denx.de> <20071102160304.GA5277@lixom.net> <1194147479.6511.11.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jwboyer@linux.vnet.ibm.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:38353 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752737AbXKDRHs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Nov 2007 12:07:48 -0500
Content-Disposition: inline
In-Reply-To: <1194147479.6511.11.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 04, 2007 at 02:37:59PM +1100, Benjamin Herrenschmidt wrote:
> 
> On Fri, 2007-11-02 at 11:03 -0500, Olof Johansson wrote:
> > On Fri, Nov 02, 2007 at 08:14:43AM +0100, Stefan Roese wrote:
> > > This patch adds support for the 405EX to the new EMAC driver. Some as on
> > > AXON, the 405EX handles the MDIO via the RGMII bridge.
> > 
> > Hi,
> > 
> > This isn't feedback on your patch as much as on "new-emac" in general:
> > 
> > Isn't this the case where there should really be device tree properties
> > instead? If you had an "ibm,emac-has-axon-stacr" property in the device
> > node, then you don't have to modify the driver for every new board out
> > there. Same for the other device properties, of course.
> > 
> > I thought this was what having the device tree was all about. :(
> 
> Somewhat yeah. There are subtle variations here or there we haven't
> totally indenfified... It might be a better option in our case here to
> add "has-mdio" to the rgmii nodes indeed.
> 
> Part of the problem with those cells is that the chip folks keep
> changing things subtly from one rev to another though, it's not even
> totally clear to me yet whether the RGMII registers are totally
> compatible betwee axon and 405ex, which is why I've pretty much stuck to
> "compatible" properties to identify the variants.
> 
> The device-tree can do both. It's still better than no device-tree since
> at least you know what cell variant is in there.

Well, it's better than compile-time ifdefs. Providing what version of
the device you have CAN be done without a device tree too. :-)

> As for the STACR, Axon isn't the first one to have that bit flipped, I
> think we should name the property differently, something like
> "stacr-oc-inverted".

Sure, it was the habit of having to modify the driver for platforms that
don't add any new features I was against. I don't really care what the
properties are called :-)

> We can still use properties that way for new things in fact. As for EMAC
> on cell, well, I can always put some fixup somewhere.

Sounds good (with s/can still/should/).


-Olof
