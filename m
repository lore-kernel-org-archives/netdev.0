From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 1/2] NET: PHY: Add PHY LED control binding.
Date: Wed, 8 Jun 2016 14:30:08 -0500
Message-ID: <20160608193008.GA20738@rob-hp-laptop>
References: <1465163150-21429-1-git-send-email-hauke@hauke-m.de>
 <1465163150-21429-2-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, alexander.stein@systec-electronic.com,
	netdev@vger.kernel.org, andrew@lunn.ch, john@phrozen.org,
	openwrt@kresin.me, hauke.mehrtens@intel.com,
	daniel.schwierzeck@gmail.com, eckert.florian@googlemail.com,
	devicetree@vger.kernel.org, thomas.langer@intel.com
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:35484 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423543AbcFHTaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 15:30:10 -0400
Content-Disposition: inline
In-Reply-To: <1465163150-21429-2-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 05, 2016 at 11:45:49PM +0200, Hauke Mehrtens wrote:
> This binding makes it possible to control the LEDs of an Ethernet PHY.
> These settings allow it to abstract the hardware configuration which
> tells the hardware when to switch the LED constant on or blink for
> example. This will be used by the Intel XWAY PHY driver.  I also
> checked datasheets for some other Ethernet PHYs and it should be
> possible to also control their LED behavior with these settings, but
> they all did not allow a so fine control over the LED behavior.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>  Documentation/devicetree/bindings/phy/phy-leds.txt | 52 ++++++++++++++++++++++
>  include/dt-bindings/phy/phy-leds.h                 | 27 +++++++++++
>  2 files changed, 79 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/phy/phy-leds.txt
>  create mode 100644 include/dt-bindings/phy/phy-leds.h

This should probably be tied into the LED bindings and subsys and be 
less Ethernet specific and less PHY specific. I find it to be a 
confusing mixture of h/w capabilities and configuration.

> 
> diff --git a/Documentation/devicetree/bindings/phy/phy-leds.txt b/Documentation/devicetree/bindings/phy/phy-leds.txt
> new file mode 100644
> index 0000000..1a35e3d
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/phy/phy-leds.txt
> @@ -0,0 +1,52 @@
> +LED configuration for Ethernet phys
> +
> +All these properties are optional, not all properties are supported by
> +all PHYs. When more then one property name is define for one LED the
> +order they get applied is device depended.
> +Property names:
> +	led-const-on: conditions the LED should be constant on
> +	led-pulse: condition the LED should be pulsed on
> +	led-blink-slow: condition the LED should slowly blink

How slow is slow?

> +	led-blink-fast: condition the LED should fast blink

How fast is fast?

> +
> +These property values define the states a LED is triggered by the
> +hardware. Not all PHYs support all states. It is possible to connect
> +these property values with OR to trigger the LED in multiple stats like
> +10MBit/s and 100MBit/s. The possible combinations are device specific.
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
> +
> +Example:
> +
> +#include <dt-bindings/phy/phy-leds.h>
> +phy@0 {
> +	compatible = "ethernet-phy-ieee802.3-c22";
> +	reg = <0x0>;
> +	#address-cells = <1>;
> +	#size-cells = <0>;
> +	led@0 {
> +		compatible = "phy,led";

phy is not a vendor prefix.

Does ethernet-phy-ieee802.3-c22 define capabilities and how to program LEDs?

> +		reg = <0>;

What does the reg value correlate to?

> +		led-const-on = <(PHY_LED_LINK10 | PHY_LED_LINK100 | PHY_LED_LINK1000)>;
> +		led-pulse = <(PHY_LED_TXACT | PHY_LED_RXACT)>;
> +	};
> +	led@2 {
> +		compatible = "phy,led";
> +		reg = <2>;
> +		led-blink-slow = <PHY_LED_EEE>;
> +		led-blink-fast = <PHY_LED_PDOWN>;
> +	};
> +};
