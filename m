From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCHv3 3/4] of: provide a binding for fixed link PHYs
Date: Thu, 15 May 2014 15:39:57 +0200
Message-ID: <20140515153957.75a8aa2a@free-electrons.com>
References: <1393930704-24374-1-git-send-email-thomas.petazzoni@ free-electrons.com>
	<1393930704-24374-4-git-send-email-thomas.petazzoni@ free-electrons.com>
	<20140308055033.BE0F2C405B0@trevor.secretlab.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Lior Amsalem <alior@marvell.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Florian Fainelli <florian@openwrt.org>,
	linux-arm-kernel@lists.infradead.org
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:56251 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752826AbaEONkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 09:40:00 -0400
In-Reply-To: <20140308055033.BE0F2C405B0@trevor.secretlab.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Grant Likely,

Sorry for bringing back this old topic, but I'm working on this again,
hopefully reaching an acceptable solution this time. One question for
you below.

On Sat, 08 Mar 2014 05:50:33 +0000, Grant Likely wrote:

> > +Example:
> > +
> > +ethernet@0 {
> > +	...
> > +	phy = <&phy0>;
> > +	phy0: phy@0 {
> > +	      fixed-link;
> > +	      speed = <1000>;
> > +	      full-duplex;
> > +	};
> 
> The phy phandle to a child node is superfluous. A phandle to a fixed
> child node doesn't make a whole lot of sense.

[...]

> There should be no address portion in the node name. It isn't a child
> device, the node is merely more configuration data for the parent.
> 
> Example:
> 
> ethernet@0 {
> 	...
> 	fixed-link {
> 	      speed = <1000>;
> 	      full-duplex;
> 	};

For my current use case, I'm personally fine with that. But that
doesn't work well with Florian Fainelli's which to potentially have the
"fixed-link" node as part of another node in the DT, in the case the
PHY is configurable through some separate SPI/I2C bus. See his comment
in http://article.gmane.org/gmane.linux.network/306789:

"""
Another problem with that "old" 'fixed-link' property is that we are
not properly capturing and representing Ethernet switches/PHYs whose
data-path are isolated from the control path. For instance such
devices will traditionally expose their control path as a
MMIO/GPIO/I2C/SPI interface. Using the 5-digit 'fixed-link' property
we are not representing this, on one side the Ethernet MAC is just
told to hardcode the link parameters with some parameters, and on
other side, any MMIO/GPIO/I2C/SPI device is not equipped with the
correct properties to express the fact that is also has a data-path
connected to an Ethernet MAC.

What I like about this new binding is that we could place the
'fixed-link' related properties in e.g: a SPI slave node, and have the
Ethernet MAC be pointed at it by a phandle to tell it: look this is
your PHY, it might not be one you could address on a MDIO bus, so I
have been providing additional properties to help you with the link
configuration.
"""

What is your opinion about this?

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
