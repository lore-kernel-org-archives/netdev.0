From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 1/2] ARM: at91/dt: describe rgmii ethernet phy
 connected to sama5d3xek boards
Date: Thu, 26 Jun 2014 11:15:13 -0700
Message-ID: <CAGVrzcbYAEMsU1SFSH761H0isQ4z1M++KK_GLf0OAbGS48YUmw@mail.gmail.com>
References: <1403777615-25685-1-git-send-email-boris.brezillon@free-electrons.com>
 <1403777615-25685-2-git-send-email-boris.brezillon@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	Andrew Victor <linux@maxim.org.za>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"David S. Miller" <davem@davemloft.net>
To: Boris BREZILLON <boris.brezillon@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403777615-25685-2-git-send-email-boris.brezillon@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Boris,

2014-06-26 3:13 GMT-07:00 Boris BREZILLON <boris.brezillon@free-electrons.com>:
> Add ethernet-phy node and specify phy interrupt (connected to pin PB25).
>
> The PHY address is not specified here because atmel have 2 different
> designs
> for its CPU modules: one is connecting PHYAD[0-2] pins to pull up resistors
> (Embest design) and the other one is connection PHYAD0 to a pull up
> resistor and PHYAD[1-2] to pull down resistors (Ronetix design).
> As a result, Ronetix design will have its PHY available at address 0x1 and
> Embest design at 0x7.
> Let the net PHY core automatically detect the PHY address by scanning the
> MDIO bus.

I though the compatible string was listed as a required property, but
it is not. The 'reg' property however is listed as required, although
the of_miodbus_register() works just fine without it, although that is
a Linux-specific implementation detail.

>
> Define board specific delays to apply to RGMII signals.
>
> Signed-off-by: Boris BREZILLON <boris.brezillon@free-electrons.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  arch/arm/boot/dts/sama5d3xcm.dtsi | 15 +++++++++++++++
>  1 file changed, 15 insertions(+)
>
> diff --git a/arch/arm/boot/dts/sama5d3xcm.dtsi b/arch/arm/boot/dts/sama5d3xcm.dtsi
> index b0b1331..fc68bae 100644
> --- a/arch/arm/boot/dts/sama5d3xcm.dtsi
> +++ b/arch/arm/boot/dts/sama5d3xcm.dtsi
> @@ -34,6 +34,21 @@
>
>                         macb0: ethernet@f0028000 {
>                                 phy-mode = "rgmii";
> +                               #address-cells = <1>;
> +                               #size-cells = <0>;
> +
> +                               ethernet-phy {
> +                                       interrupt-parent = <&pioB>;
> +                                       interrupts = <25 IRQ_TYPE_EDGE_FALLING>;
> +                                       txen-skew-ps = <800>;
> +                                       txc-skew-ps = <3000>;
> +                                       rxdv-skew-ps = <400>;
> +                                       rxc-skew-ps = <3000>;
> +                                       rxd0-skew-ps = <400>;
> +                                       rxd1-skew-ps = <400>;
> +                                       rxd2-skew-ps = <400>;
> +                                       rxd3-skew-ps = <400>;
> +                               };
>                         };
>
>                         pmc: pmc@fffffc00 {
> --
> 1.8.3.2
>
>
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel



-- 
Florian
