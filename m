From: Kumar Gala <galak@codeaurora.org>
Subject: Re: [PATCH 2/2] sh_eth: add device tree support
Date: Tue, 3 Sep 2013 17:08:28 -0500
Message-ID: <E4C90BAA-A89F-4C7C-B186-12C2DF7E6F31@codeaurora.org>
References: <201308310429.34856.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, rob.herring@calxeda.com,
	pawel.moll@arm.com, mark.rutland@arm.com, swarren@wwwdotorg.org,
	ian.campbell@citrix.com, grant.likely@linaro.org,
	devicetree@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org, rob@landley.net,
	linux-doc@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201308310429.34856.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Aug 30, 2013, at 7:29 PM, Sergei Shtylyov wrote:

> Add support of the device tree probing for the Renesas SH-Mobile SoCs.
> 
> This work is loosely based on an original patch by Nobuhiro Iwamatsu
> <nobuhiro.iwamatsu.yj@renesas.com>.
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> ---
> This patch is against Dave's 'net-next.git' repo.
> 
> Documentation/devicetree/bindings/net/sh_eth.txt |   40 +++++++++++++
> drivers/net/ethernet/renesas/sh_eth.c            |   66 ++++++++++++++++++++++-
> 2 files changed, 105 insertions(+), 1 deletion(-)
> 
> Index: net-next/Documentation/devicetree/bindings/net/sh_eth.txt
> ===================================================================
> --- /dev/null
> +++ net-next/Documentation/devicetree/bindings/net/sh_eth.txt
> @@ -0,0 +1,40 @@
> +* Renesas Electronics SH EtherMAC
> +
> +This file provides information on what the device node for the SH EtherMAC
> +interface contains.
> +
> +Required properties:
> +- compatible: "renesas,gether-r8a7740" if the device is a part of R8A7740 SoC.
> +	      "renesas,ether-r8a7779" if the device is a part of R8A7778/9 SoCs.
> +	      "renesas,ether-r8a7790" if the device is a part of R8A7790/1 SoCs.

Curious, 7779 (vs 7778) but 7790 (vs 7791).

> +- reg: offset and length of the register set for the device; if the device has
> +       TSU registers, you need to specify two register sets here.
> +- interrupt-parent: the phandle for the interrupt controller that services
> +		    interrupts for this device.
> +- interrupts: interrupt mapping for the interrupt source.
> +- phy-mode: string, operation mode of the PHY interface (a string that
> +	    of_get_phy_mode() can understand).
> +- phy-handle: phandle of the PHY device.
> +

Should add something about requiring a phy subnode

> +Optional properties:
> +- local-mac-address: 6 bytes, MAC address.

What's the assumption if local-mac-address is not specified?

> +- renesas,no-ether-link: specify when a board does not provide a proper LINK
> +			 signal.

How is this different from the fixed link concept we have?

> +- renesas,ether-link-active-low: specify when the LINK signal is active-low.
> +
> +Example (Armadillo800EVA board):
> +
> +	ethernet@e9a00000 {
> +		compatible = "renesas,gether-r8a7740";
> +		reg = <0xe9a00000 0x800>, <0xe9a01800 0x800>;
> +		interrupt-parent = <&gic>;
> +		interrupts = <0 142 0x4>;
> +		phy-mode = "mii";
> +		phy-handle = <&phy0>;
> +		#address-cells = <1>;
> +		#size-cells = <0>;
> +
> +		phy0: ethernet-phy@0 {
> +			reg = <0>;
> +		};
> +	};

- k

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, hosted by The Linux Foundation

