From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v4 net-next] mdio_bus: Issue GPIO RESET to PHYs.
Date: Mon, 24 Apr 2017 01:35:53 +0200
Message-ID: <20170423233553.GA23498@lunn.ch>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <64d6494d-41d2-0faf-a434-057f796637fe@ti.com>
 <daa29a99-0a17-d316-57eb-3e6162938d8d@ti.com>
 <f372db02-a919-55b4-9200-20726cd13482@ti.com>
 <fe0b7ec5-2f83-ba06-579f-3ea0d5c4990c@ti.com>
 <1c36aab1-3411-f76d-67f7-e3f6d9e9fda5@metafoo.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roger Quadros <rogerq@ti.com>, davem@davemloft.net,
        Florian Fainelli <f.fainelli@gmail.com>, tony@atomide.com,
        nsekhar@ti.com, jsarha@ti.com, netdev@vger.kernel.org,
        linux-omap@vger.kernel.org, linux-kernel@vger.kernel.org
To: Lars-Peter Clausen <lars@metafoo.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38710 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1046288AbdDWXgG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 23 Apr 2017 19:36:06 -0400
Content-Disposition: inline
In-Reply-To: <1c36aab1-3411-f76d-67f7-e3f6d9e9fda5@metafoo.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 21, 2017 at 03:31:09PM +0200, Lars-Peter Clausen wrote:
> On 04/21/2017 03:15 PM, Roger Quadros wrote:
> > diff --git a/Documentation/devicetree/bindings/net/mdio.txt b/Documentation/devicetree/bindings/net/mdio.txt
> > new file mode 100644
> > index 0000000..4ffbbac
> > --- /dev/null
> > +++ b/Documentation/devicetree/bindings/net/mdio.txt
> > @@ -0,0 +1,33 @@
> > +Common MDIO bus properties.
> > +
> > +These are generic properties that can apply to any MDIO bus.
> > +
> > +Optional properties:
> > +- reset-gpios: List of one or more GPIOs that control the RESET lines
> > +  of the PHYs on that MDIO bus.
> > +- reset-delay-us: RESET pulse width in microseconds as per PHY datasheet.
> > +
> > +A list of child nodes, one per device on the bus is expected. These
> > +should follow the generic phy.txt, or a device specific binding document.
> > +
> > +Example :
> > +This example shows these optional properties, plus other properties
> > +required for the TI Davinci MDIO driver.
> > +
> > +	davinci_mdio: ethernet@0x5c030000 {
> > +		compatible = "ti,davinci_mdio";
> > +		reg = <0x5c030000 0x1000>;
> > +		#address-cells = <1>;
> > +		#size-cells = <0>;
> > +
> > +		reset-gpios = <&gpio2 5 GPIO_ACTIVE_LOW>;
> > +		reset-delay-us = <2>;   /* PHY datasheet states 1us min */
> 
> If this is the reset line of the PHY shouldn't it be a property of the PHY
> node rather than of the MDIO controller node (which might have a reset on
> its own)?
> > +
> > +		ethphy0: ethernet-phy@1 {
> > +			reg = <1>;
> > +		};
> > +
> > +		ethphy1: ethernet-phy@3 {
> > +			reg = <3>;
> > +		};

Hi Lars-Peter

We discussed this when the first proposal was made. There are two
cases, to consider.

1) Here, one GPIO line resets all PHYs on the same MDIO bus. In this
example, two PHYs.

2) There is one GPIO line per PHY. That is a separate case, and as you
say, the reset line should probably be considered a PHY property, not
an MDIO property. However, it can be messy, since in order to probe
the MDIO bus, you probably need to take the PHY out of reset.

Anyway, this patch addresses the first case, so should be accepted. If
anybody wants to address the second case, they are free to do so.

	Andrew
