From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC v2 2/2] NET: PHY: lantiq: add LED configuration support
Date: Sat, 28 May 2016 20:27:09 +0200
Message-ID: <20160528182709.GJ23212@lunn.ch>
References: <1464454741-18557-1-git-send-email-hauke@hauke-m.de>
 <1464454741-18557-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, alexander.stein@systec-electronic.com,
	netdev@vger.kernel.org, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com, daniel.schwierzeck@gmail.com,
	eckert.florian@googlemail.com
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:53449 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742AbcE1S1O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2016 14:27:14 -0400
Content-Disposition: inline
In-Reply-To: <1464454741-18557-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 28, 2016 at 06:59:01PM +0200, Hauke Mehrtens wrote:
> This makes it possible to configure the behavior of the LEDs connected
> to a PHY. The LEDs are controlled by the chip, this makes it possible
> to configure the behavior when the hardware should activate and
> deactivate the LEDs.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>

Hi Hauke

This is interesting. But you definitely needs to Cc: the device tree
list.

It would also be good to see basic implementations for other PHYs, so
we know the binding is generic enough.

> +LED configuration for Ethernet phys
> +
> +Property names:
> +	led-const-on: conditions the LED should be constant on
> +	led-pules: condition the LED should be pulsed on
> +	led-blink-slow: condition the LED should slowly blink
> +	led-blink-fast: condition the LED should fast blink

A binding should make it clear if properties are required or optional.

led-pulse, not led-pules.

These properties also seem to be mutually exclusive. How can it be
constantly on, yet blink? You need better descriptions.

> +property values:
> +	PHY_LED_OFF:		LED is off
> +	PHY_LED_LINK10:		link is 10MBit/s
> +	PHY_LED_LINK100:	link is 100MBit/s
> +	PHY_LED_LINK1000:	link is 1000MBit/s
> +	PHY_LED_PDOWN:		link is powered down
> +	PHY_LED_EEE:		link is in EEE mode
> +	PHY_LED_ANEG:		auto negotiation is running
> +	PHY_LED_ABIST:		analog self testing is running
> +	PHY_LED_CDIAG:		cable diagnostics is running
> +	PHY_LED_COPPER:		copper interface detected
> +	PHY_LED_FIBER:		fiber interface detected
> +	PHY_LED_TXACT:		Transmit activity
> +	PHY_LED_RXACT:		Receive activity
> +	PHY_LED_COL:		Collision

There should be a comment that not all PHYs implement all values, or
even all properties. And some PHYS will accept an ORed list of
properties, where as other will only accept a single value.

And there should be a comment to look at the binding document for the
specific PHY for what it supports. And you need such a document for
the lantiq.

Maybe some of the implementation should be pushed into the phylib.
phy_probe() already looks for the max-speed property, so it could also
parse these properties and call a function in the phy_driver
structure.

	Andrew
