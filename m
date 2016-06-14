From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: Add Fast Ethernet MAC driver
Date: Tue, 14 Jun 2016 17:31:08 -0500
Message-ID: <20160614223108.GA5079@rob-hp-laptop>
References: <1465798076-176393-1-git-send-email-lidongpo@hisilicon.com>
 <1465798076-176393-4-git-send-email-lidongpo@hisilicon.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1465798076-176393-4-git-send-email-lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 13, 2016 at 02:07:56PM +0800, Dongpo Li wrote:
> This patch adds the Hisilicon Fast Ethernet MAC(FEMAC) driver.
> The FEMAC supports max speed 100Mbps and has been used in many
> Hisilicon SoC.
> 
> Reviewed-by: Jiancheng Xue <xuejiancheng-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> Signed-off-by: Dongpo Li <lidongpo-C8/M+/jPZTeaMJb+Lgu22Q@public.gmane.org>
> ---
>  .../devicetree/bindings/net/hisilicon-femac.txt    |   40 +
>  drivers/net/ethernet/hisilicon/Kconfig             |   12 +
>  drivers/net/ethernet/hisilicon/Makefile            |    1 +
>  drivers/net/ethernet/hisilicon/hisi_femac.c        | 1015 ++++++++++++++++++++
>  4 files changed, 1068 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/hisilicon-femac.txt
>  create mode 100644 drivers/net/ethernet/hisilicon/hisi_femac.c
> 
> diff --git a/Documentation/devicetree/bindings/net/hisilicon-femac.txt b/Documentation/devicetree/bindings/net/hisilicon-femac.txt
> new file mode 100644
> index 0000000..b953a56
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/hisilicon-femac.txt
> @@ -0,0 +1,40 @@
> +Hisilicon Fast Ethernet MAC controller
> +
> +Required properties:
> +- compatible: should be "hisilicon,hisi-femac" and one of the following:

This compatible seems a bit pointless. The following 2 are generic 
enough.

> +	* "hisilicon,hisi-femac-v1"
> +	* "hisilicon,hisi-femac-v2"

SoC specific compatible strings in addition to these please.

> +- reg: specifies base physical address(s) and size of the device registers.
> +  The first region is the MAC core register base and size.
> +  The second region is the global MAC control register.
> +- interrupts: should contain the MAC interrupt.
> +- clocks: clock phandle and specifier pair.

How many clocks?

> +- resets: should contain the phandle to the MAC reset signal(required) and
> +	the PHY reset signal(optional).
> +- reset-names: should contain the reset signal name "mac_reset"(required)
> +	and "phy_reset"(optional).
> +- mac-address: see ethernet.txt [1].
> +- phy-mode: see ethernet.txt [1].
> +- phy-handle: see ethernet.txt [1].
> +- hisilicon,phy-reset-delays: triplet of delays if PHY reset signal given.
> +	The 1st cell is reset pre-delay in micro seconds.
> +	The 2nd cell is reset pulse in micro seconds.
> +	The 3rd cell is reset post-delay in micro seconds.

Add standard unit suffixes.

> +
> +[1] Documentation/devicetree/bindings/net/ethernet.txt
> +
> +Example:
> +	hisi_femac: ethernet@10090000 {
> +		compatible = "hisilicon,hisi-femac-v2", "hisilicon,hisi-femac";
> +		reg = <0x10090000 0x1000>,<0x10091300 0x200>;
> +		interrupts = <12>;
> +		clocks = <&crg HI3518EV200_ETH_CLK>;
> +		resets = <&crg 0xec 0>,
> +				<&crg 0xec 3>;
> +		reset-names = "mac_reset",
> +				"phy_reset";
> +		mac-address = [00 00 00 00 00 00];
> +		phy-mode = "mii";
> +		phy-handle = <&phy0>;
> +		hisilicon,phy-reset-delays = <10000 20000 20000>;
> +	};
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
