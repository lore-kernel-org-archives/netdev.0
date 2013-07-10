From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: Fixed PHY Device Tree usage?
Date: Wed, 10 Jul 2013 18:22:16 +0200
Message-ID: <20130710182216.0dcfaaaf@skate>
References: <20130709183312.6c4d052d@skate>
	<CAGVrzcZ7ZLSDy5sTUR_XuSAUH=5q8ddiXx5n1y680WwGrdFfTw@mail.gmail.com>
	<1733937.SiPWt3mDlH@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory =?UTF-8?B?Q2zDqW1lbnQ=?=
	<gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	devicetree-discuss@lists.ozlabs.org, grant.likely@secretlab.ca,
	afleming@freescale.com
To: Florian Fainelli <florian@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([94.23.35.102]:41572 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754402Ab3GJQWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 12:22:22 -0400
In-Reply-To: <1733937.SiPWt3mDlH@lenovo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Florian Fainelli,

On Tue, 09 Jul 2013 19:02:05 +0100, Florian Fainelli wrote:

> > > We have a case of an hardware platform that uses the mvneta network
> > > driver, but instead of the SoC being connected to a PHY, it's connected
> > > directly to a switch, so my understanding is that there's no MDIO bus,
> > > and we should have a kind of a "fake PHY" to make the mvneta driver
> > > believe that the link is up, at a given speed.
> > 
> > Good timing, I was about to post questions/suggestions about how we
> > should represent fixed PHYs in device tree.

Great.

> > Well, it does not seem to be too far from the "hardware" reality to
> > describe a link between a switch CPU port and an Ethernet MAC as a
> > fixed PHY because that is what it really is in fact. Once you have a
> > drivers for your switch you can start using this PHY along with its
> > corresponding driver.

Ok.

> > There is a helper: of_phy_connect_fixed_link() in drivers/of/of_mdio.c
> > is flagged as being a
> > temporary solution for Freescale Ethernet drivers to move to something else,
> > so I would like to discuss what the "something else should be".

Yeah, I saw this helper function as well, and the comment you spotted.

> > Here what I would like to see the new "fixed-link" phy node look like:
> > 
> > ethernet-phy@0 {
> >      reg = <0>;
> >      id = "deadbeef";
> >      speed = <1000>;
> >      full-duplex;
> >      pause;
> >      asym-pause;
> > };
> > 
> > It has the same properties as the binding described in:
> > Documentation/devicetree/bindings/net/fsl-tsec-phy.txt but expressed in a
> > more explicit way instead of using an array of integers.

And so the fixed-phy driver would look for what exactly in the Device
Tree to find which fixed PHYs to create?

Should we have something like:

	mdio-fixed {
		compatible = "generic,mdio-fixed";
		phy0: ethernet-phy@0 {
			... all the properties you listed ...
			... maybe the "id" property is not needed
			    because of the phandle ...
		};

		phy1: ethernet-phy@1 {
			... all the properties you listed ...
			... maybe the "id" property is not needed
			    because of the phandle ...
		};
	};

	soc {
		ethernet@0 {
			phy = <&phy0>;
			...
		};

		ethernet@1 {
			phy = <&phy1>;
			...
		};
	};

or do you have in mind another representation?

Thomas
-- 
Thomas Petazzoni, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
