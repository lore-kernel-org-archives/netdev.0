From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 08/10] ARM: dts: sun7i: cubieboard2: Enable
 GMAC instead of EMAC
Date: Fri, 6 Dec 2013 13:10:19 -0800
Message-ID: <CAGVrzcYhA1S17AP8tO8m0Mjt3z=qq6feziOkwi2BwEuSPU=9Rw@mail.gmail.com>
References: <1386350983-13281-1-git-send-email-wens@csie.org> <1386350983-13281-9-git-send-email-wens@csie.org>
Reply-To: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
	Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Srinivas Kandagatla <srinivas.kandagatla-qxv4g6HH51o@public.gmane.org>
To: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
Return-path: <linux-sunxi+bncBCH67JWTV4DBBZX2RCKQKGQE2B4GR7A-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
In-Reply-To: <1386350983-13281-9-git-send-email-wens-jdAy2FN1RRM@public.gmane.org>
List-Post: <http://groups.google.com/group/linux-sunxi/post>, <mailto:linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Help: <http://groups.google.com/support/>, <mailto:linux-sunxi+help-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Archive: <http://groups.google.com/group/linux-sunxi>
Sender: linux-sunxi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org
List-Subscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:linux-sunxi+subscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Unsubscribe: <http://groups.google.com/group/linux-sunxi/subscribe>, <mailto:googlegroups-manage+1076902468213+unsubscribe-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org>
List-Id: netdev.vger.kernel.org

2013/12/6 Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>:
> GMAC has better performance and fewer hardware issues.
> Use the GMAC in MII mode for ethernet instead of the EMAC.
>
> Signed-off-by: Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>
> ---
>  arch/arm/boot/dts/sun7i-a20-cubieboard2.dts | 23 ++++++++---------------
>  1 file changed, 8 insertions(+), 15 deletions(-)
>
> diff --git a/arch/arm/boot/dts/sun7i-a20-cubieboard2.dts b/arch/arm/boot/dts/sun7i-a20-cubieboard2.dts
> index 5c51cb8..9ef5848 100644
> --- a/arch/arm/boot/dts/sun7i-a20-cubieboard2.dts
> +++ b/arch/arm/boot/dts/sun7i-a20-cubieboard2.dts
> @@ -19,21 +19,6 @@
>         compatible = "cubietech,cubieboard2", "allwinner,sun7i-a20";
>
>         soc@01c00000 {
> -               emac: ethernet@01c0b000 {
> -                       pinctrl-names = "default";
> -                       pinctrl-0 = <&emac_pins_a>;
> -                       phy = <&phy1>;
> -                       status = "okay";
> -               };
> -
> -               mdio@01c0b080 {
> -                       status = "okay";
> -
> -                       phy1: ethernet-phy@1 {
> -                               reg = <1>;
> -                       };
> -               };
> -
>                 pinctrl@01c20800 {
>                         led_pins_cubieboard2: led_pins@0 {
>                                 allwinner,pins = "PH20", "PH21";
> @@ -60,6 +45,14 @@
>                         pinctrl-0 = <&i2c1_pins_a>;
>                         status = "okay";
>                 };
> +
> +               gmac: ethernet@01c50000 {
> +                       pinctrl-names = "default";
> +                       pinctrl-0 = <&gmac_pins_mii>;
> +                       snps,phy-addr = <1>;

Same here, this is a custom property which has no reason to exist,
keep the existing ethernet PHY node please.
-- 
Florian
