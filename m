From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [RFC PATCH 1/3] of: provide a binding for the 'fixed-link'
 property
Date: Mon, 12 Aug 2013 08:38:06 +0200
Message-ID: <20130812063806.GD2324@pengutronix.de>
References: <1373902450-11857-1-git-send-email-thomas.petazzoni@free-electrons.com>
 <1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>, netdev@vger.kernel.org,
	devicetree-discuss@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:34544 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753883Ab3HLGiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 02:38:14 -0400
Content-Disposition: inline
In-Reply-To: <1373902450-11857-2-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 15, 2013 at 05:34:08PM +0200, Thomas Petazzoni wrote:
> Some Ethernet MACs have a "fixed link", and are not connected to a
> normal MDIO-managed PHY device. For those situations, a Device Tree
> binding allows to describe a "fixed link", as a "fixed-link" property
> of the Ethernet device Device Tree node.
> 
> This patch adds:
> 
>  * A documentation for the Device Tree property "fixed-link".
> 
>  * A of_phy_register_fixed_link() OF helper, which provided an OF node
>    that contains a "fixed-link" property, registers the corresponding
>    fixed PHY.
> 
>  * Removes the warning on the of_phy_connect_fixed_link() that says
>    new drivers should not use it, since Grant Likely indicated that
>    this "fixed-link" property is indeed the way to go.
> 

Any progress with this series?

We have more and more boards here with exactly the same problem as
Thomas has. For reasons stated below I don't like this binding, but
still it would solve my problem.


> +Fixed link Device Tree binding
> +------------------------------
> +
> +Some Ethernet MACs have a "fixed link", and are not connected to a
> +normal MDIO-managed PHY device. For those situations, a Device Tree
> +binding allows to describe a "fixed link".
> +
> +Such a fixed link situation is described within an Ethernet device
> +Device Tree node using a 'fixed-link' property, composed of 5
> +elements:
> +
> + 1. A fake PHY ID, which must be unique accross all fixed-link PHYs in
> +    the system.
> + 2. The duplex (1 for full-duplex, 0 for half-duplex)
> + 3. The speed (10, 100, 1000)
> + 4. The pause setting (1 for enabled, 0 for disabled)
> + 5. The asym pause setting (1 for enabled, 0 for disabled)
> +
> +Example:
> +
> +ethernet@0 {
> +	...
> +	fixed-link = <1 1 1000 0 0>;
> +	...
> +};

I must say I don't like this binding at all for two reasons.

First the positional arguments make it impossible to add optional
arguments to the link.

Second the other side of the link is most likely a switch. Once this
switch has its own node in the devicetree it seems like having a phandle
to the switch here would be better.

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
