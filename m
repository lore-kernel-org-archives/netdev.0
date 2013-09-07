From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [RFC PATCHv2 0/4] Add DT support for fixed PHYs
Date: Sat, 7 Sep 2013 12:27:26 +0200
Message-ID: <20130907122726.1af7c331@skate>
References: <1378480701-12908-1-git-send-email-thomas.petazzoni@free-electrons.com>
	<2916397.Vz9aZYzLyb@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, Lior Amsalem <alior@marvell.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Mark Rutland <mark.rutland@arm.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Christian Gmeiner <christian.gmeiner@gmail.com>
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:50005 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750979Ab3IGK1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Sep 2013 06:27:30 -0400
In-Reply-To: <2916397.Vz9aZYzLyb@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian Fainelli,

On Fri, 06 Sep 2013 21:42:42 +0100, Florian Fainelli wrote:

> > Here is a second version of the patch set that adds a Device Tree
> > binding and the related code to support fixed PHYs. Marked as RFC,
> > this patch set is obviously not intended for merging in 3.12.
> 
> Thanks a lot for continuing on this work, I really like the state of it now.

Thanks for your feedback.

> > Since the first version, the changes have been:
> > 
> >  * Instead of using a 'fixed-link' property inside the Ethernet device
> >    DT node, with a fairly cryptic succession of integer values, we now
> >    use a PHY subnode under the Ethernet device DT node, with explicit
> >    properties to configure the duplex, speed, pause and other PHY
> >    properties.
> > 
> >  * The PHY address is automatically allocated by the kernel and no
> >    longer visible in the Device Tree binding.
> > 
> >  * The PHY device is created directly when the network driver calls
> >    of_phy_connect_fixed_link(), and associated to the PHY DT node,
> >    which allows the existing of_phy_connect() function to work,
> >    without the need to use the deprecated of_phy_connect_fixed_link().
> > 
> > The things I am not entirely happy with yet are:
> > 
> >  * The PHY ID is hardcoded to 0xdeadbeef. Ideally, it should be a
> >    properly reserved vendor/device identifier, but it isn't clear how
> >    to get one allocated for this purpose.
> 
> Right, we should try to get something better, but we obviously cannot use an 
> already allocated OUI for this. Can we ask the Linux foundation or a Linux-
> friendly company to allocate one maybe?

According to http://standards.ieee.org/develop/regauth/oui/oui.txt, the
Linux Foundation doesn't seem to own any OUI. Should we simply be
contacting some random companies in this list?

> >  * The fixed_phy_register() function in drivers/net/phy/fixed.c has
> >    some OF references. So ideally, I would have preferred to put this
> >    code in drivers/of/of_mdio.c, but to call get_phy_device(), we need
> >    a reference to the mii_bus structure that represents the fixed MDIO
> >    bus.
> 
> This is not a big deal, not everything in drivers/ is consistent with this, 
> and making the fixed MDIO bus globally accessible does not sound too great.

Indeed.

> >  * There is some error management missing in fixed_phy_register(), but
> >    it can certainly be added easily. This RFC is meant to sort out the
> >    general idea.
> 
> Do you think you could add these to got beyond the RFC state? The patchset as 
> it currently is fine with me if you can address these.

Sure, it shouldn't be too difficult.

In the mean time, I'm interested in hearing comments from other people,
especially from the Device Tree bindings maintainers: while the
internal implementation details can always be fixed later on, the DT
binding should obviously get an approval from the DT maintainers.

Thanks,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
