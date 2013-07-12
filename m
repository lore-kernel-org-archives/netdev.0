From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: Fixed PHY Device Tree usage?
Date: Fri, 12 Jul 2013 13:56:12 +0200
Message-ID: <20130712135612.0f230c1d@skate>
References: <20130709183312.6c4d052d@skate>
	<CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
	<1733937.SiPWt3mDlH@lenovo>
	<20130710182216.0dcfaaaf@skate>
	<CAGVrzcbt302tTM3pprnhJz7YykUzcW=XSMCr_W=m1zWiVBX8kw@mail.gmail.com>
	<20130710183951.09a0bcea@skate>
	<CAGVrzcasmv6KvEN+okkcQA9CHjCtuRqcd=AvKLiFbPXiyS-P=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	"devicetree-discuss@lists.ozlabs.org"
	<devicetree-discuss@lists.ozlabs.org>,
	"grant.likely" <grant.likely@secretlab.ca>, afleming@freescale.com
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:49724 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932877Ab3GLL40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 07:56:26 -0400
In-Reply-To: <CAGVrzcasmv6KvEN+okkcQA9CHjCtuRqcd=AvKLiFbPXiyS-P=w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian Fainelli,

On Wed, 10 Jul 2013 18:23:30 +0100, Florian Fainelli wrote:

> >> - declare all PHY nodes in the system as sub nodes of their belonging
> >> real hardware MDIO bus node
> >> - flag specific PHY nodes as "fixed" with a "fixed-link" boolean for instance
> >> - if we see that flag, make that specific PHY node bind to the
> >> fixed-phy driver instead
> >
> > So the fixed PHY driver is going to travel through *all* nodes of the
> > DT, and whenever some random node has a "fixed" property, it's going to
> > say it corresponds to a fixed PHY? That doesn't seem like a good idea.
> 
> Why not? Since we are already have to scan the entire MDIO bus we are
> attached to, when we encounter such a PHY node with the special
> "fixed" properties, we just call fixed_phy_add() with the right
> parameters and voila. Which is also the reason why I was suggesting to
> put the "fixed" PHY nodes as sub-nodes of the real MDIO node such that
> we have this logic only in one place.

I'm still not sure to understand you here. Scanning the *entire* DT
tree and consider all nodes having a property named "fixed" as fixed
PHYs is definitely not acceptable. So I suppose you have a different
idea, but I'm still not getting it. Where in the DT would the fixed PHY
driver start looking for fixed PHYs ?

> > So that's really what I was asking: how is the fixed PHY driver going
> > to know which DT nodes to look at. Is it a platform_driver, where the
> > corresponding DT node has sub-nodes? Is it something else? Or a
> > specific compatible string?
> 
> Without DT at play here, the usual way to register a fixed PHY is:
> 
> 1) make your arch code or whatever runs before the fixed MDIO bus
> probing to call fixed_phy_add() with the expected parameters
> 2) when your ethernet driver probes its PHY devices, format the phy
> name to be bound to the fixed bus with the expected address by then
> the fixed MDIO bus would have already been probed and would find the
> fixed PHY nodes because of the first step
> 3) call of_phy_connect() from your driver to attach to the fixed PHY

Right, but that's still doesn't answer the question of how the fixed
PHY driver discovers from the DT which PHYs to instantiate.

For example, we would probably have something:

	phys {
		phy0: phy@0 {
			... PHY properties ...
		};
		phy1: phy@1 {
			... PHY properties ...
		};
	};

	soc {
		ethernet@0 {
			compatible = "...";
			...
			phy = <&phy0>;
		};
		ethernet@1 {
			compatible = "...";
			...
			phy = <&phy1>;
		};
	};

How will the fixed PHY driver know that it should instantiate
phy@0 and phy@1 as PHY devices?
	
Thanks,

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
