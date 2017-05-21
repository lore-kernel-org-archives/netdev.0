From: =?UTF-8?Q?Andreas_F=c3=a4rber?= <afaerber-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 1/1] dt-binding: net: wireless: fix node name in the
 BCM43xx example
Date: Sun, 21 May 2017 16:54:01 +0200
Message-ID: <e0b336e6-538e-eeea-0ed4-33460dbef7e0@suse.de>
References: <20170515201356.26384-1-martin.blumenstingl@googlemail.com>
 <20170515201356.26384-2-martin.blumenstingl@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Maxime Ripard <maxime.ripard-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        Chen-Yu Tsai <wens-jdAy2FN1RRM@public.gmane.org>, Shawn Guo <shawnguo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Sascha Hauer <kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
        Fabio Estevam <fabio.estevam-3arQi8VN3Tc@public.gmane.org>
To: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, mark.rutland-5wv7dgnIgG8@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170515201356.26384-2-martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am 15.05.2017 um 22:13 schrieb Martin Blumenstingl:
> The example in the BCM43xx documentation uses "brcmf" as node name.

No, it doesn't, it uses "bcrmf".

This typo has spread to all ARM device trees:

$ git grep bcrmf -- arch/arm/boot/dts/
arch/arm/boot/dts/imx6sx-nitrogen6sx.dts:       brcmf: bcrmf@1 {
arch/arm/boot/dts/imx6ul-opos6ul.dtsi:  brcmf: bcrmf@1 {
arch/arm/boot/dts/sun6i-a31s-sinovoip-bpi-m2.dts:       brcmf: bcrmf@1 {
arch/arm/boot/dts/sun7i-a20-bananapi-m1-plus.dts:       brcmf: bcrmf@1 {
arch/arm/boot/dts/sun7i-a20-bananapro.dts:      brcmf: bcrmf@1 {
arch/arm/boot/dts/sun7i-a20-cubietruck.dts:     brcmf: bcrmf@1 {
arch/arm/boot/dts/sun7i-a20-i12-tvbox.dts:      brcmf: bcrmf@1 {
arch/arm/boot/dts/sun7i-a20-wits-pro-a20-dkt.dts:       brcmf: bcrmf@1 {
arch/arm/boot/dts/sun8i-h3-bananapi-m2-plus.dts:        brcmf: bcrmf@1 {

For arch/arm64/boot/dts/amlogic/* I've already fixed it, originally by
changing to "brcmf", in a second step "wifi" was requested.

> However, wireless devices should be named "wifi" instead. Fix this to
> make sure that .dts authors can simply use the documentation as
> reference (or simply copy the node from the documentation and then
> adjust only the board specific bits).
> 
> Signed-off-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> ---
>  Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt b/Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt
> index 5dbf169cd81c..590f622188de 100644
> --- a/Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt
> +++ b/Documentation/devicetree/bindings/net/wireless/brcm,bcm43xx-fmac.txt
> @@ -31,7 +31,7 @@ mmc3: mmc@01c12000 {
>  	non-removable;
>  	status = "okay";
>  
> -	brcmf: bcrmf@1 {
> +	brcmf: wifi@1 {
>  		reg = <1>;
>  		compatible = "brcm,bcm4329-fmac";
>  		interrupt-parent = <&pio>;

Thanks for fixing this at its source.

Hopefully the maintainers in CC can make sure that at least it doesn't
spread further into new DTs.

Regards,
Andreas

-- 
SUSE Linux GmbH, Maxfeldstr. 5, 90409 Nürnberg, Germany
GF: Felix Imendörffer, Jane Smithard, Graham Norton
HRB 21284 (AG Nürnberg)
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
