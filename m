From: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Subject: Re: [PATCH v7 02/10] arm: dts: sunxi: Restore EMAC changes
Date: Wed, 18 Oct 2017 18:44:50 +0200
Message-ID: <20171018164450.GE15371@lunn.ch>
References: <20171018114458.17891-1-clabbe.montjoie@gmail.com>
 <20171018114458.17891-3-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, wens-jdAy2FN1RRM@public.gmane.org,
        linux-I+IVW8TIWO2tmTQ+vhA3Yw@public.gmane.org, catalin.marinas-5wv7dgnIgG8@public.gmane.org,
        will.deacon-5wv7dgnIgG8@public.gmane.org, peppe.cavallaro-qxv4g6HH51o@public.gmane.org,
        alexandre.torgue-qxv4g6HH51o@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
        frowand.list-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
To: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20171018114458.17891-3-clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 18, 2017 at 01:44:50PM +0200, Corentin Labbe wrote:
> The original dwmac-sun8i DT bindings have some issue on how to handle
> integrated PHY and was reverted in last RC of 4.13.
> But now we have a solution so we need to get back that was reverted.
> 
> This patch restore arm DT about dwmac-sun8i
> This reverts commit fe45174b72ae ("arm: dts: sunxi: Revert EMAC changes")
> 
> Signed-off-by: Corentin Labbe <clabbe.montjoie-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts |  9 ++++++++
>  arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts   | 19 +++++++++++++++++
>  arch/arm/boot/dts/sun8i-h3-nanopi-m1-plus.dts     | 19 +++++++++++++++++
>  arch/arm/boot/dts/sun8i-h3-nanopi-neo.dts         |  7 ++++++
>  arch/arm/boot/dts/sun8i-h3-orangepi-2.dts         |  8 +++++++
>  arch/arm/boot/dts/sun8i-h3-orangepi-one.dts       |  8 +++++++
>  arch/arm/boot/dts/sun8i-h3-orangepi-pc-plus.dts   |  5 +++++
>  arch/arm/boot/dts/sun8i-h3-orangepi-pc.dts        |  8 +++++++
>  arch/arm/boot/dts/sun8i-h3-orangepi-plus.dts      | 22 +++++++++++++++++++
>  arch/arm/boot/dts/sun8i-h3-orangepi-plus2e.dts    | 16 ++++++++++++++
>  arch/arm/boot/dts/sunxi-h3-h5.dtsi                | 26 +++++++++++++++++++++++
>  11 files changed, 147 insertions(+)
> 
> diff --git a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
> index b1502df7b509..6713d0f2b3f4 100644
> --- a/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
> +++ b/arch/arm/boot/dts/sun8i-h2-plus-orangepi-zero.dts
> @@ -56,6 +56,8 @@
>  
>  	aliases {
>  		serial0 = &uart0;
> +		/* ethernet0 is the H3 emac, defined in sun8i-h3.dtsi */
> +		ethernet0 = &emac;
>  		ethernet1 = &xr819;
>  	};
>  
> @@ -102,6 +104,13 @@
>  	status = "okay";
>  };
>  
> +&emac {
> +	phy-handle = <&int_mii_phy>;
> +	phy-mode = "mii";
> +	allwinner,leds-active-low;
> +	status = "okay";
> +};
> +
>  &mmc0 {
>  	pinctrl-names = "default";
>  	pinctrl-0 = <&mmc0_pins_a>;
> diff --git a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts b/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> index e1dba9ffa94b..f2292deaa590 100644
> --- a/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> +++ b/arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts
> @@ -52,6 +52,7 @@
>  	compatible = "sinovoip,bpi-m2-plus", "allwinner,sun8i-h3";
>  
>  	aliases {
> +		ethernet0 = &emac;
>  		serial0 = &uart0;
>  		serial1 = &uart1;
>  	};
> @@ -111,6 +112,24 @@
>  	status = "okay";
>  };
>  
> +&emac {
> +	pinctrl-names = "default";
> +	pinctrl-0 = <&emac_rgmii_pins>;
> +	phy-supply = <&reg_gmac_3v3>;
> +	phy-handle = <&ext_rgmii_phy>;
> +	phy-mode = "rgmii";
> +
> +	allwinner,leds-active-low;
> +	status = "okay";
> +};
> +


> +&external_mdio {
> +	ext_rgmii_phy: ethernet-phy@1 {
> +		compatible = "ethernet-phy-ieee802.3-c22";
> +		reg = <0>;
> +	};
> +};
> +

Hi Corentin

I'm wondering about the order of the patches. Does the external_mdio
node actually exist at this point? Or only later when other patches
are applied?

    Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
