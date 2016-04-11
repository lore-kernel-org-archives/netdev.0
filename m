From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC 1/5] net: phy: sun8i-h3-ephy: Add bindings for
 Allwinner H3 Ethernet PHY
Date: Mon, 11 Apr 2016 12:23:28 -0700
Message-ID: <570BF9B0.2090602@gmail.com>
References: <1459786954-12649-1-git-send-email-wens@csie.org>
 <1459786954-12649-2-git-send-email-wens@csie.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org,
	LABBE Corentin <clabbe.montjoie@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: Chen-Yu Tsai <wens@csie.org>,
	Maxime Ripard <maxime.ripard@free-electrons.com>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459786954-12649-2-git-send-email-wens@csie.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/04/16 09:22, Chen-Yu Tsai wrote:
> The Allwinner H3 SoC incorporates an Ethernet PHY. This is enabled and
> configured through a memory mapped hardware register.
> 
> This same register also configures the MAC interface mode and TX clock
> source. Also covered by the register, but not supported in these bindings,
> are TX/RX clock delay chains and inverters, and an RMII module.
> 
> Signed-off-by: Chen-Yu Tsai <wens@csie.org>
> ---
>  .../bindings/net/allwinner,sun8i-h3-ephy.txt       | 44 ++++++++++++++++++++++
>  1 file changed, 44 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt b/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
> new file mode 100644
> index 000000000000..146f227e6d88
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/allwinner,sun8i-h3-ephy.txt
> @@ -0,0 +1,44 @@
> +* Allwinner H3 E(thernet) PHY
> +
> +The Allwinner H3 integrates an MII ethernet PHY. As with external PHYs,
> +before it can be configured over the MDIO bus and used, certain hardware
> +features must be configured, such as the PHY address and LED polarity.

Is the internal PHY address really configurable? Not that there is
anything wrong with it, this is good.

> +The PHY must also be powered on and brought out of reset.
> +
> +This is accomplished with regulators and pull-up/downs for external PHYs.
> +For this internal PHY, a hardware register is programmed.
> +
> +The same hardware register also contains clock and interface controls
> +for the MAC. This is also present in earlier SoCs, and is covered by
> +"allwinner,sun7i-a20-gmac-clk". The controls in the H3 are slightly
> +different due to the inclusion of what appears to be an RMII-MII
> +bridge.
> +
> +Required properties:
> +- compatible: should be "allwinner,sun8i-h3-ephy"
> +- reg: address and length of the register set for the device
> +- clocks: A phandle to the reference clock for this device
> +- resets: A phandle to the reset control for this device
> +
> +Ethernet PHY related properties:
> +- allwinner,ephy-addr: the MDIO bus address the PHY should respond to.
> +		       If this is not set, the external PHY is used, and
> +		       everything else in this section is ignored.

So we are going to put the same value here, and in the actual Ethernet
PHY device tree node that should be hanging off the EMAC/MDIO bus
controller, this is confusing and error prone.

> +- allwinner,leds-active-low: LEDs are active low. Without this, LEDs are
> +			     active high.
> +
> +Ethernet MAC clock related properties:
> +- #clock-cells: should be 0
> +- clock-output-names: "mac_tx"
> +
> +Example:
> +
> +ethernet-phy@01c00030 {
> +	compatible = "allwinner,sun8i-h3-ephy";
> +	reg = <0x01c00030 0x4>;

Looking at this register space this looks more like an internal PHY SHIM
that is needed to be configured before the internal PHY can be access,
not a proper Ethernet PHY per-se, see replies in aptch 2.

Should not this block be a second cell associated with the Ethernet MAC
block? One or the other are not going to be very useful without
knowledge of each other.
-- 
Florian
