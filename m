From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH v5 2/3] Documentation: DT: net: Add Xilinx gmiitorgmii
 converter device tree binding documentation
Date: Tue, 9 Aug 2016 14:50:09 -0700
Message-ID: <638248c5-1747-0a7d-58e6-27b7646c4f6d@gmail.com>
References: <1470735283-23611-1-git-send-email-appanad@xilinx.com>
 <1470735283-23611-3-git-send-email-appanad@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Kedareswara rao Appana <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, michal.simek-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org,
	soren.brinkmann-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org,
	punnaia-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1470735283-23611-3-git-send-email-appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/09/2016 02:34 AM, Kedareswara rao Appana wrote:
> Device-tree binding documentation for xilinx gmiitorgmii converter.
> 
> Signed-off-by: Kedareswara rao Appana <appanad-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
> ---
> Changes for v5:
> ---> Fixed Indentation in the example as suggested by Michal.
> Changes for v4:
> --> Modified compatible as suggested by Rob.
> --> Removed underscores from the converter node name as suggested by Rob.
> Changes for v3:
> --> None.
> Changes for v2:
> --> New patch.
> 
>  .../devicetree/bindings/net/xilinx_gmii2rgmii.txt  | 38 ++++++++++++++++++++++
>  1 file changed, 38 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> new file mode 100644
> index 0000000..5f48793
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/xilinx_gmii2rgmii.txt
> @@ -0,0 +1,38 @@
> +XILINX GMIITORGMII Converter Driver Device Tree Bindings
> +--------------------------------------------------------
> +
> +The Gigabit Media Independent Interface (GMII) to Reduced Gigabit Media
> +Independent Interface (RGMII) core provides the RGMII between RGMII-compliant
> +Ethernet physical media devices (PHY) and the Gigabit Ethernet controller.
> +This core can be used in all three modes of operation(10/100/1000 Mb/s).
> +The Management Data Input/Output (MDIO) interface is used to configure the
> +Speed of operation. This core can switch dynamically between the three
> +Different speed modes by configuring the conveter register through mdio write.
> +
> +The MDIO is a bus to which the PHY devices are connected.  For each
> +device that exists on this bus, a child node should be created.  See
> +the definition of the PHY node in booting-without-of.txt for an example
> +of how to define a PHY.

I would skip this paragraph which does not really help with
understanding, and just refer to
Documentation/devicetree/bindings/net/phy.txt for examples.


> +
> +This converter sits between the ethernet MAC and the external phy.
> +MAC <==> GMII2RGMII <==> RGMII_PHY
> +
> +Required properties:
> +- compatible	: Should be "xlnx,gmii-to-rgmii-1.0"
> +- reg		: The ID number for the phy, usually a small integer

You would want specify that "reg" property needs to match the one of the
PHY (specified via phy-handle) you are converting to/from for this
"proxy" piece of hardware to work.

If these two have the same "reg" value, is not that going to lead to
duplicate MDIO devices created on the bus, this may work, based on
probing ordering, but seems unusual, you don't really need the "reg"
property here it seems?

> +- phy-handle	: Should point to the external phy device.
> +		  See ethernet.txt file in the same directory.
> +
> +Example:
> +	mdio {
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +		phy: ethernet-phy@0 {
> +			......
> +		};
> +		gmiitorgmii: gmiitorgmii@8 {
> +			compatible = "xlnx,gmii-to-rgmii-1.0";
> +			reg = <8>;
> +			phy-handle = <&phy>;
> +		};
> +	};
> 


-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
