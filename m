From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [RFC PATCH 1/3] of: provide a binding for the 'fixed-link'
 property
Date: Mon, 12 Aug 2013 10:16:49 +0200
Message-ID: <20130812101649.743c08aa@skate>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com>
	<20130812063806.GD2324@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org
To: Sascha Hauer <s.hauer@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:52442 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754180Ab3HLIRa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 04:17:30 -0400
In-Reply-To: <20130812063806.GD2324@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Sascha Hauer,

On Mon, 12 Aug 2013 08:38:06 +0200, Sascha Hauer wrote:

> > This patch adds:
> > 
> >  * A documentation for the Device Tree property "fixed-link".
> > 
> >  * A of_phy_register_fixed_link() OF helper, which provided an OF node
> >    that contains a "fixed-link" property, registers the corresponding
> >    fixed PHY.
> > 
> >  * Removes the warning on the of_phy_connect_fixed_link() that says
> >    new drivers should not use it, since Grant Likely indicated that
> >    this "fixed-link" property is indeed the way to go.
> > 
> 
> Any progress with this series?

I am not sure there really was a consensus yet on what the DT binding
looks like. As soon as there is a consensus, I'm definitely willing to
make progress on this series.

> We have more and more boards here with exactly the same problem as
> Thomas has. For reasons stated below I don't like this binding, but
> still it would solve my problem.

Ok.

> > +Example:
> > +
> > +ethernet@0 {
> > +	...
> > +	fixed-link = <1 1 1000 0 0>;
> > +	...
> > +};
> 
> I must say I don't like this binding at all for two reasons.

As I explained, this binding was chosen for this RFC for two reasons:

 * It's the binding used on PowerPC platforms to represent fixed links.
 * It allows to encode all the informations into a single property,
   which avoids the need for a separate DT node for a "fake PHY", which
   isn't a representation of the hardware.

> First the positional arguments make it impossible to add optional
> arguments to the link.
> 
> Second the other side of the link is most likely a switch. Once this
> switch has its own node in the devicetree it seems like having a phandle
> to the switch here would be better.

So, in other words, what you're suggesting is something like:

	ethernet@0 {
		reg = <...>;
		interrupt = <...>;
		phy = <&phy0>;
		phy0: phy@0 {
			fixed-link;
			speed = <1000>;
			full-duplex;
			...
		};
	};

Or something else?

Best regards,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
