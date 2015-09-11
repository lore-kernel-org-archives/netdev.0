From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH/RFC v2 net-next 3/4] ravb: Document binding for r8a7795
 SoC
Date: Fri, 11 Sep 2015 17:25:17 +0300
Message-ID: <55F2E44D.6010505@cogentembedded.com>
References: <1441936878-18290-1-git-send-email-horms+renesas@verge.net.au>
 <1441936878-18290-4-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Magnus Damm <magnus.damm@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
To: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
	linux-sh@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <1441936878-18290-4-git-send-email-horms+renesas@verge.net.au>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 9/11/2015 5:01 AM, Simon Horman wrote:

> From: Kazuya Mizuguchi <kazuya.mizuguchi.ks@renesas.com>
>
> This patch updates the ravb binding to support the r8a7795 SoC by:
> - Adding a compat string for the new hardware
> - Adding 25 named interrupts to binding for the new SoC;
>    older SoCs continue to use a single multiplexed interrupt
>
> The example is also updated to reflect the r8a7795 as this is the
> more complex case.
>
> Based on work by Kazuya Mizuguchi and others.
>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
>
> ---
>
> v2
> * First post; broken out of a driver update patch
> * As discussed with Geert Uytterhoeven and Sergei Shtylyov
>    - Binding: Make all interrupts mandatory as named-interrupts of
>      the form ch%u
> ---
>   .../devicetree/bindings/net/renesas,ravb.txt       | 65 +++++++++++++++++++---
>   1 file changed, 58 insertions(+), 7 deletions(-)
>
> diff --git a/Documentation/devicetree/bindings/net/renesas,ravb.txt b/Documentation/devicetree/bindings/net/renesas,ravb.txt
> index 1fd8831437bf..6c360f993d33 100644
> --- a/Documentation/devicetree/bindings/net/renesas,ravb.txt
> +++ b/Documentation/devicetree/bindings/net/renesas,ravb.txt
[...]
> @@ -27,13 +33,46 @@ Optional properties:
>   Example:
>
>   	ethernet@e6800000 {
> -		compatible = "renesas,etheravb-r8a7790";
> -		reg = <0 0xe6800000 0 0x800>, <0 0xee0e8000 0 0x4000>;
> +		compatible = "renesas,etheravb-r8a7795";
> +		reg = <0 0xe6800000 0 0x800>, <0 0xe6a00000 0 0x10000>;
>   		interrupt-parent = <&gic>;
> -		interrupts = <0 163 IRQ_TYPE_LEVEL_HIGH>;
> -		clocks = <&mstp8_clks R8A7790_CLK_ETHERAVB>;
> -		phy-mode = "rmii";
> +		interrupts = <GIC_SPI 39 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 40 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 41 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 42 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 43 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 44 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 45 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 46 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 47 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 48 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 49 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 50 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 51 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 52 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 53 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 54 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 55 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 56 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 57 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 58 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 59 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 60 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 61 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 62 IRQ_TYPE_LEVEL_HIGH>,
> +			     <GIC_SPI 63 IRQ_TYPE_LEVEL_HIGH>;
> +		interrupt-names = "ch0", "ch1", "ch2", "ch3",
> +				  "ch4", "ch5", "ch6", "ch7",
> +				  "ch8", "ch9", "ch10", "ch11",
> +				  "ch12", "ch13", "ch14", "ch15",
> +				  "ch16", "ch17", "ch18", "ch19",
> +				  "ch20", "ch21", "ch22", "ch23",
> +				  "ch24";

    To me, these names don't look very helpful. You could as well omit them 
and use platform_get_irq() with the channel #.

> +		clocks = <&mstp8_clks R8A7795_CLK_ETHERAVB>;
> +		phy-mode = "rgmii-id";
> +		phy-reset-gpio = <&gpio2 10 0>;

    I don't see how this prop is used by the driver and it's not documented in 
the bindings.

[...]

MBR, Sergei

