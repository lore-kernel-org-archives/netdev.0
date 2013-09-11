From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [RFC PATCHv2 0/4] Add DT support for fixed PHYs
Date: Wed, 11 Sep 2013 08:42:48 +0200
Message-ID: <20130911064248.GI30088@pengutronix.de>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Mark Rutland <mark.rutland@arm.com>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57598 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3IKGmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 02:42:54 -0400
Content-Disposition: inline
In-Reply-To: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 06, 2013 at 05:18:17PM +0200, Thomas Petazzoni wrote:
> Hello,
> 
> Here is a second version of the patch set that adds a Device Tree
> binding and the related code to support fixed PHYs. Marked as RFC,
> this patch set is obviously not intended for merging in 3.12.
> 
> Since the first version, the changes have been:
> 
>  * Instead of using a 'fixed-link' property inside the Ethernet device
>    DT node, with a fairly cryptic succession of integer values, we now
>    use a PHY subnode under the Ethernet device DT node, with explicit
>    properties to configure the duplex, speed, pause and other PHY
>    properties.
> 
>  * The PHY address is automatically allocated by the kernel and no
>    longer visible in the Device Tree binding.
> 
>  * The PHY device is created directly when the network driver calls
>    of_phy_connect_fixed_link(), and associated to the PHY DT node,
>    which allows the existing of_phy_connect() function to work,
>    without the need to use the deprecated of_phy_connect_fixed_link().
> 
> The things I am not entirely happy with yet are:
> 
>  * The PHY ID is hardcoded to 0xdeadbeef. Ideally, it should be a
>    properly reserved vendor/device identifier, but it isn't clear how
>    to get one allocated for this purpose.
> 
>  * The fixed_phy_register() function in drivers/net/phy/fixed.c has
>    some OF references. So ideally, I would have preferred to put this
>    code in drivers/of/of_mdio.c, but to call get_phy_device(), we need
>    a reference to the mii_bus structure that represents the fixed MDIO
>    bus.
> 
>  * There is some error management missing in fixed_phy_register(), but
>    it can certainly be added easily. This RFC is meant to sort out the
>    general idea.

+1 for the general idea. This really looks good now. I've not much more
to say. Maybe someone from the devicetree corner has a few words for the
binding?

Sascha

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
