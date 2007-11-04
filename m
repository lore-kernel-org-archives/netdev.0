From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: Add 405EX support to new EMAC driver
Date: Sun, 04 Nov 2007 14:37:59 +1100
Message-ID: <1194147479.6511.11.camel@pasglop>
References: <200711020814.43524.sr@denx.de>
	 <20071102160304.GA5277@lixom.net>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jwboyer@linux.vnet.ibm.com
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:39996 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756891AbXKDDjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Nov 2007 23:39:07 -0400
In-Reply-To: <20071102160304.GA5277@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Fri, 2007-11-02 at 11:03 -0500, Olof Johansson wrote:
> On Fri, Nov 02, 2007 at 08:14:43AM +0100, Stefan Roese wrote:
> > This patch adds support for the 405EX to the new EMAC driver. Some as on
> > AXON, the 405EX handles the MDIO via the RGMII bridge.
> 
> Hi,
> 
> This isn't feedback on your patch as much as on "new-emac" in general:
> 
> Isn't this the case where there should really be device tree properties
> instead? If you had an "ibm,emac-has-axon-stacr" property in the device
> node, then you don't have to modify the driver for every new board out
> there. Same for the other device properties, of course.
> 
> I thought this was what having the device tree was all about. :(

Somewhat yeah. There are subtle variations here or there we haven't
totally indenfified... It might be a better option in our case here to
add "has-mdio" to the rgmii nodes indeed.

Part of the problem with those cells is that the chip folks keep
changing things subtly from one rev to another though, it's not even
totally clear to me yet whether the RGMII registers are totally
compatible betwee axon and 405ex, which is why I've pretty much stuck to
"compatible" properties to identify the variants.

The device-tree can do both. It's still better than no device-tree since
at least you know what cell variant is in there.

As for the STACR, Axon isn't the first one to have that bit flipped, I
think we should name the property differently, something like
"stacr-oc-inverted".

We can still use properties that way for new things in fact. As for EMAC
on cell, well, I can always put some fixup somewhere.

Ben. 

