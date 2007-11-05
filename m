From: Stefan Roese <sr@denx.de>
Subject: Re: [PATCH] net: Add 405EX support to new EMAC driver
Date: Mon, 5 Nov 2007 10:19:03 +0100
Message-ID: <200711051019.04287.sr@denx.de>
References: <200711020814.43524.sr@denx.de> <20071102160304.GA5277@lixom.net> <1194147479.6511.11.camel@pasglop>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jwboyer@linux.vnet.ibm.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.179]:64224 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752393AbXKEJTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 04:19:12 -0500
In-Reply-To: <1194147479.6511.11.camel@pasglop>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 04 November 2007, Benjamin Herrenschmidt wrote:
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

So how exactly do you want me to handle this (I'm still new to this device 
tree stuff, so please bear with me)? Like this?

			RGMII0: emac-rgmii@ef601000 {
				device_type = "rgmii-interface";
				compatible = "ibm,rgmii-405ex", "ibm,rgmii";
				reg = <ef601000 8>;
				has-mdio;
			};

Or add this to the compatible property?

			RGMII0: emac-rgmii@ef601000 {
				device_type = "rgmii-interface";
				compatible = "ibm,rgmii-405ex", "ibm,rgmii", "ibm,has-mdio";
				reg = <ef601000 8>;
			};

> Part of the problem with those cells is that the chip folks keep
> changing things subtly from one rev to another though, it's not even
> totally clear to me yet whether the RGMII registers are totally
> compatible betwee axon and 405ex, which is why I've pretty much stuck to
> "compatible" properties to identify the variants.
>
> The device-tree can do both. It's still better than no device-tree since
> at least you know what cell variant is in there.
>
> As for the STACR, Axon isn't the first one to have that bit flipped, I
> think we should name the property differently, something like
> "stacr-oc-inverted".

It's not only the OC bit-flip on AXON, but also the different STACR register 
layout for read/write op-codes (STAOPC). This seems to be the same on all new 
EMAC core's like on AXON, 440EPx/GRx and 405EX. So "stacr-oc-inverted" is not 
enough here. This is what is needed for 440SPe, which "only" has the bit-flip 
and the "old" STAOPC layout.

So perhaps most flexible would be to add individual properties, 
like "stacr-oc-inverted" and "stacr-staopc-19-20". What do you think? And 
again the additional question: Should the be added as an new property or 
added to the compatible property?

Please advise. Thanks.

Best regards,
Stefan
