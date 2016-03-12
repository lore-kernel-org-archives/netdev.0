From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH RFC v2 00/32] Make DSA switches linux devices.
Date: Sat, 12 Mar 2016 18:08:27 +0100
Message-ID: <20160312170827.GA2186@lunn.ch>
References: <1456677700-23027-1-git-send-email-andrew@lunn.ch>
 <56D88757.7050803@gmail.com>
 <20160303202716.GQ15541@lunn.ch>
 <56E357C7.7090309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:55430 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751959AbcCLRIb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Mar 2016 12:08:31 -0500
Content-Disposition: inline
In-Reply-To: <56E357C7.7090309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [snip]
>
> >
> > The third switch is as you would expect, dsa,member = <0 2>;
>
> I like that representation.
>

...

> So does that mean you agree we do not need the DSA platform device
> anymore :)?

It looks like it can be	done without the DSA platform device.

My previous approach was to keep the new binding as similar as
possible to the current one. If however, we decide we are going for
something totally new, we can remove this platform device.

It probably means we need to turn slave.c and parts of dsa.c into a
library. Add a new dsa_v2.c file, containing the new binding
code. With things like having the switch devices instantiate there own
MDIO bus, fixed phys on a compatible MDIO bus referenced via phandles,
etc, I hope we can make parts of the dsa_v2 simpler.

> Very true, we support a wide variety of setups, and that creates a lot
> of complexity that could probably be absorbed by a more generic helper
> function?

No, i want to go the other direction. Make all these phy setups look
identical. It is just a phy-handle=<&phandle> property. With my MDIO
fixed-phy bus patches, it just works for user ports, and the only
thing we need to deal with is phy-mode.

DSA and CPU ports are harder, due to a lack of a netdev. Horrible, but
maybe would could do a alloc_netdev(), but never register_netdev()?
It gives us something to attach the phy to.

> > 1) The switch device should use mdiobus_alloc()/mdiobus_register() for
> > its own MDIO bus.
> 
> Agreed, possibly with the help of the DSA slave code, since some of that
> is already doing its magic for most drivers here.

I think the switch driver should instantiate the MDIO bus, not the
core. The core could however offer some helper code.

      Andrew
