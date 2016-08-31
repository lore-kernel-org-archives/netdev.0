From: Doug Anderson <dianders-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [RESEND PATCH 3/4] arm64: dts: rockchip: support gmac for rk3399
Date: Wed, 31 Aug 2016 13:42:17 -0700
Message-ID: <CAD=FV=XQX__rFqGLY2U5mPT8WR4P4aW5tbCqFmA+3rZunbzUZQ@mail.gmail.com>
References: <1472624028-7082-1-git-send-email-wxt@rock-chips.com> <1472624028-7082-4-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Heiko Stuebner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Brian Norris <briannorris-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Derek Basehore <dbasehore-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        Catalin Marinas <catalin.marinas-5wv7dgnIgG8@public.gmane.org>,
        Will Deacon <will.deacon-5wv7dgnIgG8@public.gmane.org>,
        Xing Zheng <zhengxing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        Jianqun Xu <jay.xu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Elaine Zhang <zhangqing-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        David Wu <david.wu-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        Shunqian Zheng <zhengsq-TNX95d0MmH7DzftRWevZcw@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel@li
To: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1472624028-7082-4-git-send-email-wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Caesar,

On Tue, Aug 30, 2016 at 11:13 PM, Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org> wrote:
> This patch adds needed gamc information for rk3399,
> also support the gmac pd.
>
> Signed-off-by: Roger Chen <roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> Signed-off-by: Caesar Wang <wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org>
> ---
>
>  arch/arm64/boot/dts/rockchip/rk3399.dtsi | 90 ++++++++++++++++++++++++++++++++
>  1 file changed, 90 insertions(+)

I noticed that your subject for this patch contains "RESEND" and not
"v2" event though there are changes between this version and the last
one.  That's really confusing.  This should have been "v2" and the
next version should be "v3".


> diff --git a/arch/arm64/boot/dts/rockchip/rk3399.dtsi b/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> index 32aebc8..abf27a4 100644
> --- a/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> +++ b/arch/arm64/boot/dts/rockchip/rk3399.dtsi
> @@ -200,6 +200,26 @@
>                 };
>         };
>
> +       gmac: eth@fe300000 {

nit: on rk3288 the node was "ethernet@" instead of "eth@".  Presumably
"ethernet" is more correct?

> +               compatible = "rockchip,rk3399-gmac";
> +               reg = <0x0 0xfe300000 0x0 0x10000>;
> +               interrupts = <GIC_SPI 12 IRQ_TYPE_LEVEL_HIGH>;
> +               interrupt-names = "macirq";
> +               clocks = <&cru SCLK_MAC>, <&cru SCLK_MAC_RX>,
> +                        <&cru SCLK_MAC_TX>, <&cru SCLK_MACREF>,
> +                        <&cru SCLK_MACREF_OUT>, <&cru ACLK_GMAC>,
> +                        <&cru PCLK_GMAC>;
> +               clock-names = "stmmaceth", "mac_clk_rx",
> +                             "mac_clk_tx", "clk_mac_ref",
> +                             "clk_mac_refout", "aclk_mac",
> +                             "pclk_mac";
> +               power-domains = <&power RK3399_PD_GMAC>;
> +               resets = <&cru SRST_A_GMAC>;
> +               reset-names = "stmmaceth";
> +               rockchip,grf = <&grf>;
> +               status = "disabled";
> +       };
> +
>         sdio0: dwmmc@fe310000 {
>                 compatible = "rockchip,rk3399-dw-mshc",
>                              "rockchip,rk3288-dw-mshc";
> @@ -611,6 +631,11 @@
>                 status = "disabled";
>         };
>
> +       qos_gmac: qos@ffa5c000 {
> +               compatible = "syscon";
> +               reg = <0x0 0xffa5c000 0x0 0x20>;
> +       };
> +
>         qos_hdcp: qos@ffa90000 {
>                 compatible = "syscon";
>                 reg = <0x0 0xffa90000 0x0 0x20>;
> @@ -704,6 +729,11 @@
>                         #size-cells = <0>;
>
>                         /* These power domains are grouped by VD_CENTER */
> +                       pd_gmac@RK3399_PD_GMAC {

RK3399_PD_GMAC is not in VD_CENTER but in VD_LOGIC, right?  ...so this
should move.

> +                               reg = <RK3399_PD_GMAC>;
> +                               clocks = <&cru ACLK_GMAC>;
> +                               pm_qos = <&qos_gmac>;
> +                       };

IMHO it would be nice if this were broken into two patches.

1. First patch would be the power domain patch and that could land any
time.  You wouldn't actually be able to use the gmac but at least
you'd be able to turn off its power.  This would be a handy patch to
be able to backport if you happened to not need Ethernet support but
wanted to save power.

2. Second patch would actually add the gmac.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
