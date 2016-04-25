From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v2 net-next] net: ethernet: enc28j60: add device tree
 support
Date: Mon, 25 Apr 2016 08:23:26 -0500
Message-ID: <20160425132326.GA17445@rob-hp-laptop>
References: <31567588.rB9VrggOb6@wuerfel>
 <1461533283-24852-1-git-send-email-mhei@heimpold.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonathan Cameron <jic23@kernel.org>,
	"Andrew F . Davis" <afd@ti.com>, Mark Brown <broonie@kernel.org>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>
To: Michael Heimpold <mhei@heimpold.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:53566 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932174AbcDYNXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 09:23:31 -0400
Content-Disposition: inline
In-Reply-To: <1461533283-24852-1-git-send-email-mhei@heimpold.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 24, 2016 at 11:28:03PM +0200, Michael Heimpold wrote:
> The following patch adds the required match table for device tree support
> (and while at, fix the indent). It's also possible to specify the
> MAC address in the DT blob.
> 
> Also add the corresponding binding documentation file.
> 
> Signed-off-by: Michael Heimpold <mhei@heimpold.de>
> ---
> 
> v2: * took care of Arnd Bergmann's review comments
>       - allow to specify MAC address via DT
>       - unconditionally define DT id table
>     * increased the driver version minor number
>     * driver author's email address bounces, removed from address list
> 
>  .../devicetree/bindings/net/microchip-enc28j60.txt | 50 ++++++++++++++++++++++

Matching the compatible string is preferred here: microchip,enc28j60.txt

>  drivers/net/ethernet/microchip/enc28j60.c          | 20 +++++++--
>  2 files changed, 67 insertions(+), 3 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/microchip-enc28j60.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/microchip-enc28j60.txt b/Documentation/devicetree/bindings/net/microchip-enc28j60.txt
> new file mode 100644
> index 0000000..847a97b
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/microchip-enc28j60.txt
> @@ -0,0 +1,50 @@
> +* Microchip ENC28J60
> +
> +This is a standalone 10 MBit ethernet controller with SPI interface.
> +
> +For each device connected to a SPI bus, define a child node within
> +the SPI master node.
> +
> +Required properties:
> +- compatible: Should be "microchip,enc28j60"
> +- reg: Specify the SPI chip select the ENC28J60 is wired to
> +- interrupts: Specify the interrupt and interrupt type (usually falling edge)
> +
> +Optional properties:
> +- interrupt-parent: Specify the pHandle of the source interrupt

This is required in the sense that either the node or a parent node must 
define it. In this case, since the SPI controller likely has a different 
parent, you will pretty much always need it defined in this node.

> +- spi-max-frequency: Maximum frequency of the SPI bus when accessing the ENC28J60.
> +  According to the ENC28J80 datasheet, the chip allows a maximum of 20 MHz, however,
> +  board designs may need to limit this value.
> +- local-mac-address: See ethernet.txt in the same directory.
> +
> +
> +Example (for NXP i.MX28 with pin control stuff for GPIO irq):
> +
> +        ssp2: ssp@80014000 {
> +                compatible = "fsl,imx28-spi";
> +                pinctrl-names = "default";
> +                pinctrl-0 = <&spi2_pins_b &spi2_sck_cfg>;
> +                status = "okay";
> +
> +                enc28j60: ethernet@0 {
> +                        compatible = "microchip,enc28j60";
> +                        pinctrl-names = "default";
> +                        pinctrl-0 = <&enc28j60_pins>;

Need to document using the pinctrl binding.

> +                        reg = <0>;
> +                        interrupt-parent = <&gpio3>;
> +                        interrupts = <3 IRQ_TYPE_EDGE_FALLING>;
> +                        spi-max-frequency = <12000000>;
> +                };
> +        };
> +
