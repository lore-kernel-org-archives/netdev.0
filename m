From: Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Subject: Re: [PATCH net-next v2 1/2] dt-bindings: net: add DT bindings for
 Socionext UniPhier AVE
Date: Sat, 14 Oct 2017 01:41:12 +0900
Message-ID: <CAK7LNATkHsbr4cOh_F6u0Fznui3BFXfWJXgKwCk0EZANSmk0pg@mail.gmail.com>
References: <1507854928-4357-1-git-send-email-hayashi.kunihiko@socionext.com> <1507854928-4357-2-git-send-email-hayashi.kunihiko@socionext.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Masami Hiramatsu <masami.hiramatsu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1507854928-4357-2-git-send-email-hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2017-10-13 9:35 GMT+09:00 Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>:
> DT bindings for the AVE ethernet controller found on Socionext's
> UniPhier platforms.
>
> Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
> Signed-off-by: Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> ---
>  .../bindings/net/socionext,uniphier-ave4.txt       | 53 ++++++++++++++++++++++
>  1 file changed, 53 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
>
> diff --git a/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt b/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
> new file mode 100644
> index 0000000..25f4d92
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/socionext,uniphier-ave4.txt
> @@ -0,0 +1,53 @@
> +* Socionext AVE ethernet controller
> +
> +This describes the devicetree bindings for AVE ethernet controller
> +implemented on Socionext UniPhier SoCs.
> +
> +Required properties:
> + - compatible: Should be
> +       - "socionext,uniphier-pro4-ave4" : for Pro4 SoC
> +       - "socionext,uniphier-pxs2-ave4" : for PXs2 SoC
> +       - "socionext,uniphier-ld20-ave4" : for LD20 SoC
> +       - "socionext,uniphier-ld11-ave4" : for LD11 SoC

Nit.  LD11, LD20, in this order please.

> + - reg: Address where registers are mapped and size of region.
> + - interrupts: Should contain the MAC interrupt.
> + - phy-mode: See ethernet.txt in the same directory. Allow to choose
> +       "rgmii", "rmii", or "mii" according to the PHY.
> + - pinctrl-names: List of assigned state names, see pinctrl
> +       binding documentation.
> + - pinctrl-0: List of phandles to configure the GPIO pin,


configure the GPIO pin?

git-grep found this phrase.


$ git grep "List of phandles to configure the GPIO"
Documentation/devicetree/bindings/net/microchip,enc28j60.txt:-
pinctrl-0: List of phandles to configure the GPIO pin used as
interrupt line,





> +       see pinctrl binding documentation. Choose this appropriately
> +       according to phy-mode.
> +       - <&pinctrl_ether_rgmii> if phy-mode is "rgmii".
> +       - <&pinctrl_ether_rmii> if phy-mode is "rmii".
> +       - <&pinctrl_ether_mii> if phy-mode is "mii".

pinctrl_ether_rgmii is just a label
you just happened to write in your DT file.

This information is totally unrelated to hardware specification.
It is not stable, either.



> + - phy-handle: Should point to the external phy device.
> +       See ethernet.txt file in the same directory.
> + - mdio subnode: Should be device tree subnode with the following required
> +       properties:
> +       - #address-cells: Must be <1>.
> +       - #size-cells: Must be <0>.
> +       - reg: phy ID number, usually a small integer.


Are you talking about "Required subnode" in the "Required properties"?




> +Optional properties:
> + - local-mac-address: See ethernet.txt in the same directory.
> +
> +Example:
> +
> +       ether: ethernet@65000000 {
> +               compatible = "socionext,uniphier-ld20-ave4";
> +               reg = <0x65000000 0x8500>;
> +               interrupts = <0 66 4>;
> +               pinctrl-names = "default";
> +               pinctrl-0 = <&pinctrl_ether_rgmii>;
> +               phy-mode = "rgmii";
> +               phy-handle = <&ethphy>;
> +               local-mac-address = [00 00 00 00 00 00];
> +               mdio {
> +                       #address-cells = <1>;
> +                       #size-cells = <0>;
> +                       ethphy: ethphy@1 {
> +                               reg = <1>;
> +                       };
> +               };
> +       };
> --
> 2.7.4
>



-- 
Best Regards
Masahiro Yamada
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
