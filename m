From: Lars-Peter Clausen <lars@metafoo.de>
Subject: Re: [PATCH v4 net-next] mdio_bus: Issue GPIO RESET to PHYs.
Date: Fri, 21 Apr 2017 15:31:09 +0200
Message-ID: <1c36aab1-3411-f76d-67f7-e3f6d9e9fda5@metafoo.de>
References: <1491381237-24635-1-git-send-email-rogerq@ti.com>
 <64d6494d-41d2-0faf-a434-057f796637fe@ti.com>
 <daa29a99-0a17-d316-57eb-3e6162938d8d@ti.com>
 <f372db02-a919-55b4-9200-20726cd13482@ti.com>
 <fe0b7ec5-2f83-ba06-579f-3ea0d5c4990c@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, nsekhar@ti.com, jsarha@ti.com,
        netdev@vger.kernel.org, linux-omap@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, davem@davemloft.net,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <fe0b7ec5-2f83-ba06-579f-3ea0d5c4990c@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/21/2017 03:15 PM, Roger Quadros wrote:
> diff --git a/Documentation/devicetree/bindings/net/mdio.txt b/Documentation/devicetree/bindings/net/mdio.txt
> new file mode 100644
> index 0000000..4ffbbac
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/mdio.txt
> @@ -0,0 +1,33 @@
> +Common MDIO bus properties.
> +
> +These are generic properties that can apply to any MDIO bus.
> +
> +Optional properties:
> +- reset-gpios: List of one or more GPIOs that control the RESET lines
> +  of the PHYs on that MDIO bus.
> +- reset-delay-us: RESET pulse width in microseconds as per PHY datasheet.
> +
> +A list of child nodes, one per device on the bus is expected. These
> +should follow the generic phy.txt, or a device specific binding document.
> +
> +Example :
> +This example shows these optional properties, plus other properties
> +required for the TI Davinci MDIO driver.
> +
> +	davinci_mdio: ethernet@0x5c030000 {
> +		compatible = "ti,davinci_mdio";
> +		reg = <0x5c030000 0x1000>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		reset-gpios = <&gpio2 5 GPIO_ACTIVE_LOW>;
> +		reset-delay-us = <2>;   /* PHY datasheet states 1us min */

If this is the reset line of the PHY shouldn't it be a property of the PHY
node rather than of the MDIO controller node (which might have a reset on
its own)?

> +
> +		ethphy0: ethernet-phy@1 {
> +			reg = <1>;
> +		};
> +
> +		ethphy1: ethernet-phy@3 {
> +			reg = <3>;
> +		};
