From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] [v5] net: emac: emac gigabit ethernet controller driver
Date: Sun, 19 Jun 2016 09:17:57 -0500
Message-ID: <20160619141757.GA4249@rob-hp-laptop>
References: <1465942955-22988-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, andrew@lunn.ch,
	bjorn.andersson@linaro.org, mlangsdo@redhat.com, jcm@redhat.com,
	agross@codeaurora.org, davem@davemloft.net, f.fainelli@gmail.com
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1465942955-22988-1-git-send-email-timur@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 14, 2016 at 05:22:35PM -0500, Timur Tabi wrote:
> Add supports for ethernet controller HW on Qualcomm Technologies, Inc. SoC.
> This driver supports the following features:
> 1) Checksum offload.
> 2) Interrupt coalescing support.
> 3) SGMII phy.
> 4) phylib interface for external phy
> 
> Based on original work by
> 	Niranjana Vishwanathapura <nvishwan@codeaurora.org>
> 	Gilad Avidov <gavidov@codeaurora.org>
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
> 
> v5:
>  - changed author to Timur, added MAINTAINERS entry
>  - use phylib, replacing internal phy code
>  - added support for EMAC internal SGMII v2
>  - fix ~DIS_INT warning
>  - update DT bindings, including removing unused properties
>  - removed interrupt handler for internal sgmii
>  - removed link status check handler/state (replaced with phylib)
>  - removed periodic timer handler (replaced with phylib)
>  - removed power management code (will be rewritten later)
>  - external phy is now required, not optional
>  - removed redundant EMAC_STATUS_DOWN status flag
>  - removed redundant link status and speed variables
>  - removed redundant status bits (vlan strip, promiscuous, loopback, etc)
>  - removed useless watchdog status
>  - removed command-line parameters
>  - cleaned up probe messages
>  - removed redundant params from emac_sgmii_link_init()
>  - always call netdev_completed_queue() (per review comment)
>  - fix emac_napi_rtx() (per review comment)
>  - removed max_ints loop in interrupt handler
>  - removed redundant mutex around phy read/write calls
>  - added lock for reading emac status (per review comment)
>  - generate random MAC address if it can't be read from firmware
>  - replace EMAC_DMA_ADDR_HI/LO with upper/lower_32_bits
>  - don't test return value from platform_get_resource (per review comment)
>  - use net_warn_ratelimited (per review comment)
>  - don't set the dma masks (will be set by DT or IORT code)
>  - remove unused emac_tx_tpd_ts_save()
>  - removed redundant local MTU variable
> 
> v4:
>  - add missing ipv6 header file
>  - correct compatible string
>  - fix spacing in emac_reg_write arrays
>  - drop unnecessary cell-index property
>  - remove unsupported DT properties from docs
>  - remove GPIO initialization and update docs
> 
> v3:
>  - remove most of the memory barriers by using the non xxx_relaxed() api.
>  - remove RSS and WOL support.
>  - correct comments from physical address to dma address.
>  - rearrange structs to make them packed.
>  - replace polling loops with readl_poll_timeout().
>  - remove unnecessary wrapper functions from phy layer.
>  - add blank line before return statements.
>  - set to null clocks after clk_put().
>  - use module_platform_driver() and dma_set_mask_and_coherent()
>  - replace long hex bitmasks with BIT() macro.
> 
> v2:
>  - replace hw bit fields to macros with bitwise operations.
>  - change all iterators to unsized types (int)
>  - some minor code flow improvements.
>  - change return type to void for functions which return value is never
>    used.
>  - replace instance of xxxxl_relaxed() io followed by mb() with a
>    readl()/writel().
> 
> 
>  .../devicetree/bindings/net/qcom-emac.txt          |   66 +
>  MAINTAINERS                                        |    6 +
>  drivers/net/ethernet/qualcomm/Kconfig              |   11 +
>  drivers/net/ethernet/qualcomm/Makefile             |    2 +
>  drivers/net/ethernet/qualcomm/emac/Makefile        |    7 +
>  drivers/net/ethernet/qualcomm/emac/emac-mac.c      | 1674 ++++++++++++++++++++
>  drivers/net/ethernet/qualcomm/emac/emac-mac.h      |  284 ++++
>  drivers/net/ethernet/qualcomm/emac/emac-phy.c      |  211 +++
>  drivers/net/ethernet/qualcomm/emac/emac-phy.h      |   32 +
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.c    |  699 ++++++++
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.h    |   24 +
>  drivers/net/ethernet/qualcomm/emac/emac.c          |  798 ++++++++++
>  drivers/net/ethernet/qualcomm/emac/emac.h          |  370 +++++
>  13 files changed, 4184 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/qcom-emac.txt
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/Makefile
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-mac.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-mac.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-phy.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-phy.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac-sgmii.h
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac.c
>  create mode 100644 drivers/net/ethernet/qualcomm/emac/emac.h
> 
> diff --git a/Documentation/devicetree/bindings/net/qcom-emac.txt b/Documentation/devicetree/bindings/net/qcom-emac.txt
> new file mode 100644
> index 0000000..e48a9b9
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
> @@ -0,0 +1,66 @@
> +Qualcomm EMAC Gigabit Ethernet Controller
> +
> +Required properties:
> +- compatible : Should be "qcom,fsm9900-emac".
> +- reg : Offset and length of the register regions for the device
> +- reg-names : Register region names referenced in 'reg' above.
> +	Required register resource entries are:
> +	"base"   : EMAC controller base register block.
> +	"csr"    : EMAC wrapper register block.
> +	"sgmii"  : EMAC SGMII PHY register block.
> +	Optional register resource entries are:
> +	"ptp"    : EMAC PTP (1588) register block.
> +- interrupts : Interrupt numbers used by this controller
> +- interrupt-names : Interrupt resource names referenced in 'interrupts' above.
> +	Required interrupt resource entries are:
> +	"emac_core0"   : EMAC core0 interrupt.
> +	"sgmii_irq"   : EMAC SGMII interrupt.
> +- mac-address               : The 6-byte MAC address. If present, it is the
> +			      default MAC address.
> +
> +Optional properties:
> +The external phy child node:
> +- compatible : Should be "qcom,fsm9900-emac-phy".
> +- reg : The phy address
> +
> +Example:
> +soc {
> +	#address-cells = <1>;
> +	#size-cells = <1>;
> +
> +	emac0: qcom,emac@feb20000 {

ethernet@...

> +		compatible = "qcom,fsm9900-emac";
> +		#address-cells = <1>;
> +		#size-cells = <1>;
> +		reg-names = "base", "csr", "ptp", "sgmii";
> +		reg =   <0xfeb20000 0x10000>,
> +			<0xfeb36000 0x1000>,
> +			<0xfeb3c000 0x4000>,
> +			<0xfeb38000 0x400>;
> +		dma-ranges = <0 0 0xffffffff>;

I believe dma-ranges is supposed to be in the bus (parent) node.

> +		interrupt-parent = <&emac0>;
> +		#interrupt-cells = <1>;
> +		interrupts = <0 1>;
> +		interrupt-map-mask = <0xffffffff>;
> +		interrupt-map = <0 &intc 0 76 0
> +				 1 &intc 0 80 0>;

Why? This looks unnecessary.

> +		interrupt-names = "emac_core0", "sgmii_irq";
> +		phy0: ethernet-phy@0 {
> +			compatible = "qcom,fsm9900-emac-phy";
> +			reg = <0>;
> +		}
> +
> +		pinctrl-names = "default";
> +		pinctrl-0 = <&mdio_pins_a>;
> +	};
> +
> +	tlmm: pinctrl@fd510000 {
> +		compatible = "qcom,fsm9900-pinctrl";
> +
> +		mdio_pins_a: mdio {
> +			state {
> +				pins = "gpio123", "gpio124";
> +				function = "mdio";
> +			};
> +		};
> +	};
