From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Thu, 31 Dec 2015 17:10:39 -0600
Message-ID: <20151231231039.GA8886@rob-hp-laptop>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-msm@vger.kernel.org,
	sdharia@codeaurora.org, shankerd@codeaurora.org,
	timur@codeaurora.org, gregkh@linuxfoundation.org,
	vikrams@codeaurora.org, cov@codeaurora.org
To: Gilad Avidov <gavidov@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Dec 29, 2015 at 06:48:55PM -0700, Gilad Avidov wrote:
> Add supports for ethernet controller HW on Qualcomm Technologies, Inc. SoC.
> This driver supports the following features:
> 1) Checksum offload.
> 2) Runtime power management support.
> 3) Interrupt coalescing support.
> 4) SGMII phy.
> 5) SGMII direct connection without external phy.
> 
> Based on a driver by Niranjana Vishwanathapura
> <nvishwan@codeaurora.org>.

[...]

> diff --git a/Documentation/devicetree/bindings/net/qcom-emac.txt b/Documentation/devicetree/bindings/net/qcom-emac.txt
> new file mode 100644
> index 0000000..8d58a40
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
> @@ -0,0 +1,68 @@
> +Qualcomm EMAC Gigabit Ethernet Controller
> +
> +Required properties:
> +- cell-index : EMAC controller instance number.
> +- compatible : Should be "qcom,emac".

This should be more specific with the SOC name.

> +- reg : Offset and length of the register regions for the device
> +- reg-names : Register region names referenced in 'reg' above.
> +	Required register resource entries are:
> +	"base"   : EMAC controller base register block.
> +	"csr"    : EMAC wrapper register block.
> +	Optional register resource entries are:
> +	"ptp"    : EMAC PTP (1588) register block.
> +		   Required if 'qcom,emac-tstamp-en' is present.
> +	"sgmii"  : EMAC SGMII PHY register block.
> +- interrupts : Interrupt numbers used by this controller
> +- interrupt-names : Interrupt resource names referenced in 'interrupts' above.
> +	Required interrupt resource entries are:
> +	"emac_core0"   : EMAC core0 interrupt.
> +	"sgmii_irq"   : EMAC SGMII interrupt.
> +- qcom,emac-gpio-mdc  : GPIO pin number of the MDC line of MDIO bus.
> +- qcom,emac-gpio-mdio : GPIO pin number of the MDIO line of MDIO bus.

Use the standard binding for GPIO controlled MDIO bus.

> +- phy-addr            : Specifies phy address on MDIO bus.
> +			Required if the optional property "qcom,no-external-phy"
> +			is not specified.

Don't you think you will need to know the specific phy device or other 
properties of the phy?

> +
> +Optional properties:
> +- qcom,emac-tstamp-en       : Enables the PTP (1588) timestamping feature.
> +			      Include this only if PTP (1588) timestamping
> +			      feature is needed. If included, "ptp" register
> +			      base should be specified.

Isn't this a user enabled feature if the h/w supports it?

> +- mac-address               : The 6-byte MAC address. If present, it is the
> +			      default MAC address.
> +- qcom,no-external-phy      : Indicates there is no external PHY connected to
> +			      EMAC. Include this only if the EMAC is directly
> +			      connected to the peer end without EPHY.
> +- qcom,emac-ptp-grandmaster : Enable the PTP (1588) grandmaster mode.
> +			      Include this only if PTP (1588) is configured as
> +			      grandmaster.
> +- qcom,emac-ptp-frac-ns-adj : The vector table to adjust the fractional ns per
> +			      RTC clock cycle.
> +			      Include this only if there is accuracy loss of
> +			      fractional ns per RTC clock cycle. For individual
> +			      table entry, the first field indicates the RTC
> +			      reference clock rate. The second field indicates
> +			      the number of adjustment in 2 ^ -26 ns.
> +Example:
> +	emac0: qcom,emac@feb20000 {
> +		cell-index = <0>;
> +		compatible = "qcom,emac";
> +		reg-names = "base", "csr", "ptp", "sgmii";
> +		reg =   <0xfeb20000 0x10000>,
> +			<0xfeb36000 0x1000>,
> +			<0xfeb3c000 0x4000>,
> +			<0xfeb38000 0x400>;
> +		#address-cells = <0>;
> +		interrupt-parent = <&emac0>;
> +		#interrupt-cells = <1>;
> +		interrupts = <0 1>;
> +		interrupt-map-mask = <0xffffffff>;
> +		interrupt-map = <0 &intc 0 76 0
> +				 1 &intc 0 80 0>;
> +		interrupt-names = "emac_core0", "sgmii_irq";
> +		qcom,emac-gpio-mdc = <&qcomgpio 123 0>;
> +		qcom,emac-gpio-mdio = <&qcomgpio 124 0>;
> +		qcom,emac-tstamp-en;
> +		qcom,emac-ptp-frac-ns-adj = <125000000 1>;
> +		phy-addr = <0>;
> +	};
