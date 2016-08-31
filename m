From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH] [v9] net: emac: emac gigabit ethernet controller driver
Date: Wed, 31 Aug 2016 10:00:43 -0500
Message-ID: <20160831150043.GA575@rob-hp-laptop>
References: <1472161143-26417-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
        bjorn.andersson-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, mlangsdo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jcm-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        agross-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org
To: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1472161143-26417-1-git-send-email-timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 25, 2016 at 04:39:03PM -0500, Timur Tabi wrote:
> Add support for the Qualcomm Technologies, Inc. EMAC gigabit Ethernet
> controller.
> 
> This driver supports the following features:
> 1) Checksum offload.
> 2) Interrupt coalescing support.
> 3) SGMII phy.
> 4) phylib interface for external phy
> 
> Based on original work by
> 	Niranjana Vishwanathapura <nvishwan-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> 	Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> 
> Signed-off-by: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
> ---
> 
> v9:
>  - Define a separate DT node for the internal phy
>  - Kconfig option now selects required PHYLIB
>  - Use netdev_alloc_skb_ip_align
>  - Use devm functions for enabling clocks
>  - Remove redundancy from the Makefile
>  - Fix error messages and clean up error paths
>  - Miscellaneous reformatting
> 
>  .../devicetree/bindings/net/qcom-emac.txt          |  112 ++
>  MAINTAINERS                                        |    6 +
>  drivers/net/ethernet/qualcomm/Kconfig              |   12 +
>  drivers/net/ethernet/qualcomm/Makefile             |    2 +
>  drivers/net/ethernet/qualcomm/emac/Makefile        |    7 +
>  drivers/net/ethernet/qualcomm/emac/emac-mac.c      | 1530 ++++++++++++++++++++
>  drivers/net/ethernet/qualcomm/emac/emac-mac.h      |  248 ++++
>  drivers/net/ethernet/qualcomm/emac/emac-phy.c      |  203 +++
>  drivers/net/ethernet/qualcomm/emac/emac-phy.h      |   33 +
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.c    |  722 +++++++++
>  drivers/net/ethernet/qualcomm/emac/emac-sgmii.h    |   24 +
>  drivers/net/ethernet/qualcomm/emac/emac.c          |  751 ++++++++++
>  drivers/net/ethernet/qualcomm/emac/emac.h          |  335 +++++
>  13 files changed, 3985 insertions(+)
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
> index 0000000..4599c78
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/qcom-emac.txt
> @@ -0,0 +1,112 @@
> +Qualcomm Technologies EMAC Gigabit Ethernet Controller
> +
> +This network controller consists of two devices: a MAC and an SGMII
> +internal PHY.  Each device is represented by a device tree node.  A phandle
> +connects the MAC node to its corresponding internal phy node.  Another
> +phandle points to the external PHY node.
> +
> +Required properties:
> +
> +MAC node:
> +- compatible : Should be "qcom,fsm9900-emac".
> +- reg : Offset and length of the register regions for the device
> +- interrupts : Interrupt number used by this controller
> +- mac-address : The 6-byte MAC address. If present, it is the default
> +	MAC address.
> +- internal-phy : phandle to the internal PHY node
> +- phy-handle : phandle the the external PHY node
> +
> +Internal PHY node:
> +- compatible : Should be "qcom,fsm9900-emac-sgmii" or "qcom,qdf2432-emac-sgmii".
> +- reg : Offset and length of the register region(s) for the device
> +- interrupts : Interrupt number used by this controller
> +
> +The external phy child node:
> +- reg : The phy address
> +
> +Example:
> +
> +FSM9900:
> +
> +soc {
> +	#address-cells = <1>;
> +	#size-cells = <1>;
> +
> +	emac0: ethernet@feb20000 {
> +		compatible = "qcom,fsm9900-emac";
> +		reg = <0xfeb20000 0x10000>,
> +		      <0xfeb36000 0x1000>;
> +		interrupts = <76>;
> +
> +		clocks = <&gcc 0>, <&gcc 1>, <&gcc 3>, <&gcc 4>, <&gcc 5>,
> +			<&gcc 6>, <&gcc 7>;
> +		clock-names = "axi_clk", "cfg_ahb_clk", "high_speed_clk",
> +			"mdio_clk", "tx_clk", "rx_clk", "sys_clk";
> +
> +		internal-phy = <&emac_sgmii>;

Can't this use the standard generic phy binding (i.e. 'phys'). It's a 
bit confusing as there's the ethernet phy binding (phy-handle) and the 
generic one. 

> +
> +		phy-handle = <&phy0>;

This is bit redundant as the phy is the child node. I guess if you had 
multiple devices on the mdio bus you would need it. I'd drop it if you 
don't envision needing it and the kernel doesn't require it.

> +
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		phy0: ethernet-phy@0 {

It's just an example, but don't we require compatible strings for phys 
now?

> +			reg = <0>;
> +		};
> +
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
