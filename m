From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH can-next 1/2] CAN: rcar: add gen[12] fallback
 compatibility strings
Date: Mon, 22 Feb 2016 16:40:39 +0100
Message-ID: <CAMuHMdX3VjAZzhNxuucBn3hSS3YMmhJPVxpA2VKM+X-Qs3gxLg@mail.gmail.com>
References: <1456107350-12100-1-git-send-email-horms+renesas@verge.net.au>
	<1456107350-12100-2-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-renesas-soc@vger.kernel.org,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <1456107350-12100-2-git-send-email-horms+renesas@verge.net.au>
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 22, 2016 at 3:15 AM, Simon Horman
<horms+renesas@verge.net.au> wrote:
> Add fallback compatibility string for R-Car Gen 1 and Gen2 families.
> This is in keeping with the fallback scheme being adopted wherever
> appropriate for drivers for Renesas SoCs.
>
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> ---
>  Documentation/devicetree/bindings/net/can/rcar_can.txt | 4 +++-
>  drivers/net/can/rcar_can.c                             | 2 ++
>  2 files changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/devicetree/bindings/net/can/rcar_can.txt b/Documentation/devicetree/bindings/net/can/rcar_can.txt
> index 002d8440bf66..036786e1f70d 100644
> --- a/Documentation/devicetree/bindings/net/can/rcar_can.txt
> +++ b/Documentation/devicetree/bindings/net/can/rcar_can.txt
> @@ -6,6 +6,8 @@ Required properties:
>               "renesas,can-r8a7779" if CAN controller is a part of R8A7779 SoC.
>               "renesas,can-r8a7790" if CAN controller is a part of R8A7790 SoC.
>               "renesas,can-r8a7791" if CAN controller is a part of R8A7791 SoC.
> +             "renesas,can-gen1" for a generic R-Car Gen1 compatible device.
> +             "renesas,can-gen2" for a generic R-Car Gen2 compatible device.

"renesas,rcar-gen1-can", "renesas,rcar-gen2-can"?

(Yeah, "can" looks a lot like "rcar" ;-)

Nothing further to say about SoC-specific vs. generic compatible values?

>  - reg: physical base address and size of the R-Car CAN register map.
>  - interrupts: interrupt specifier for the sole interrupt.
>  - clocks: phandles and clock specifiers for 3 CAN clock inputs.
> @@ -25,7 +27,7 @@ Example
>  SoC common .dtsi file:
>
>         can0: can@e6e80000 {
> -               compatible = "renesas,can-r8a7791";
> +               compatible = "renesas,can-r8a7791", "renesas,can-gen2";

"renesas,rcar-gen2-can".

>                 reg = <0 0xe6e80000 0 0x1000>;
>                 interrupts = <0 186 IRQ_TYPE_LEVEL_HIGH>;
>                 clocks = <&mstp9_clks R8A7791_CLK_RCAN0>,
> diff --git a/drivers/net/can/rcar_can.c b/drivers/net/can/rcar_can.c
> index bc46be39549d..c70a1f795933 100644
> --- a/drivers/net/can/rcar_can.c
> +++ b/drivers/net/can/rcar_can.c
> @@ -904,6 +904,8 @@ static const struct of_device_id rcar_can_of_table[] __maybe_unused = {
>         { .compatible = "renesas,can-r8a7779" },
>         { .compatible = "renesas,can-r8a7790" },
>         { .compatible = "renesas,can-r8a7791" },
> +       { .compatible = "renesas,can-gen1" },
> +       { .compatible = "renesas,can-gen2" },

"renesas,rcar-gen1-can"
"renesas,rcar-gen2-can".

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
