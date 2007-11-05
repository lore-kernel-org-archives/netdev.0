From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH] net: Add 405EX support to new EMAC driver
Date: Mon, 05 Nov 2007 22:04:11 +1100
Message-ID: <1194260652.6511.70.camel@pasglop>
References: <200711020814.43524.sr@denx.de>
	 <20071102160304.GA5277@lixom.net> <1194147479.6511.11.camel@pasglop>
	 <200711051019.04287.sr@denx.de>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Olof Johansson <olof@lixom.net>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jwboyer@linux.vnet.ibm.com
To: Stefan Roese <sr@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60215 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753771AbXKELFj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 06:05:39 -0500
In-Reply-To: <200711051019.04287.sr@denx.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Mon, 2007-11-05 at 10:19 +0100, Stefan Roese wrote:
> 
> > Somewhat yeah. There are subtle variations here or there we haven't
> > totally indenfified... It might be a better option in our case here
> to
> > add "has-mdio" to the rgmii nodes indeed.
> 
> So how exactly do you want me to handle this (I'm still new to this
> device 
> tree stuff, so please bear with me)? Like this?
> 
>                         RGMII0: emac-rgmii@ef601000 {
>                                 device_type = "rgmii-interface";
>                                 compatible = "ibm,rgmii-405ex",
> "ibm,rgmii";
>                                 reg = <ef601000 8>;
>                                 has-mdio;
>                         };
> 

The above.

Properties without values are typically used for such "flags". I'll
fixup the driver to also take that for the inverted STACR and will post
a patch fixing that up asap.

> It's not only the OC bit-flip on AXON, but also the different STACR
> register 
> layout for read/write op-codes (STAOPC). This seems to be the same on
> all new 
> EMAC core's like on AXON, 440EPx/GRx and 405EX. So "stacr-oc-inverted"
> is not 
> enough here. This is what is needed for 440SPe, which "only" has the
> bit-flip 
> and the "old" STAOPC layout.

Ok.

> So perhaps most flexible would be to add individual properties, 
> like "stacr-oc-inverted" and "stacr-staopc-19-20". What do you think?
> And 
> again the additional question: Should the be added as an new property
> or 
> added to the compatible property?

That's always the main question imho ... When it gets nasty like that I
tend to think the compatible property is a good compromise. It's mostly
a matter of taste. Unless you can come up with some more pleasant way to
do it... maybe a stacr-type property with multiple values but it's
really not worth complicating things when a compatible property will do
the job just fine. In that case, it's not really a "feature" of a given
implementation, but more about subtle differences between
implementations.

Ben.


