From: Heiko =?ISO-8859-1?Q?St=FCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH 3/4] arm64: dts: rockchip: support gmac for rk3399
Date: Wed, 31 Aug 2016 00:07:51 +0200
Message-ID: <1912883.KWCSTxJEHB@diego>
References: <1472589008-7713-1-git-send-email-wxt@rock-chips.com> <1472589008-7713-4-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Douglas Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org, Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        Jianqun Xu <jay.xu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        Elaine Zhang <zhangqing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Shunqian Zheng <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472589008-7713-4-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 31. August 2016, 04:30:06 schrieb Caesar Wang:
> This patch adds needed gamc information for rk3399,
> also support the gmac pd.
> 
> Signed-off-by: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> ---
> 
>  arch/arm64/boot/dts/rockchip/rk3399.dtsi | 90
> ++++++++++++++++++++++++++++++++ 1 file changed, 90 insertions(+)
> 
> diff --git a/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> b/arch/arm64/boot/dts/rockchip/rk3399.dtsi index 32aebc8..53ac651 100644
> --- a/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> +++ b/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> @@ -200,6 +200,26 @@
>  		};
>  	};
> 
> +	gmac: eth@fe300000 {
> +		compatible = "rockchip,rk3399-gmac";
> +		reg = <0x0 0xfe300000 0x0 0x10000>;
> +		rockchip,grf = <&grf>;

should move below the reset-names .

> +		interrupts = <GIC_SPI 12 IRQ_TYPE_LEVEL_HIGH>;
> +		interrupt-names = "macirq";
> +		clocks = <&cru SCLK_MAC>, <&cru SCLK_MAC_RX>,
> +			 <&cru SCLK_MAC_TX>, <&cru SCLK_MACREF>,
> +			 <&cru SCLK_MACREF_OUT>, <&cru ACLK_GMAC>,
> +			 <&cru PCLK_GMAC>;
> +		clock-names = "stmmaceth", "mac_clk_rx",
> +			      "mac_clk_tx", "clk_mac_ref",
> +			      "clk_mac_refout", "aclk_mac",
> +			      "pclk_mac";
> +		resets = <&cru SRST_A_GMAC>;
> +		reset-names = "stmmaceth";
> +		power-domains = <&power RK3399_PD_GMAC>;

The driver core should handle regular power-domain handling on device creation 
already, right? So I should be able to apply patches 3 and 4 even without the 
dwmac patches, right?

Also if resending please move power-domains above resets


Heiko
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
