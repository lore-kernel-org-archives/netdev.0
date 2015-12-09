From: Moritz Fischer <moritz.fischer@ettus.com>
Subject: Re: [PATCH] net/macb: add support for resetting PHY using GPIO
Date: Wed, 9 Dec 2015 10:27:34 -0800
Message-ID: <CAAtXAHcHGC+5HJrCNTPhwhLSMmOPtMrjCYBRQxbzGq3GrML8Yw@mail.gmail.com>
References: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Devicetree List <devicetree@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1449683383-5022-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Gregory,

so far dealt with this in u-boot. The power down the PHY part makes
sense, though. Minor nit down inline.
Will need to test on hardware (Zynq).

On Wed, Dec 9, 2015 at 9:49 AM, Gregory CLEMENT
<gregory.clement@free-electrons.com> wrote:
> With device tree it is no more possible to reset the PHY at board
> level. Furthermore, doing in the driver allow to power down the PHY when
> the network interface is no more used.
>
> The patch introduces a new optional property "phy-reset-gpio" inspired
> from the one use for the FEC.
>
> Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
> ---
>  Documentation/devicetree/bindings/net/macb.txt |  3 +++
>  drivers/net/ethernet/cadence/macb.c            | 26 ++++++++++++++++++++++++++
>  drivers/net/ethernet/cadence/macb.h            |  1 +
>  3 files changed, 30 insertions(+)
>
> diff --git a/Documentation/devicetree/bindings/net/macb.txt b/Documentation/devicetree/bindings/net/macb.txt
> index b5d7976..546d34d 100644
> --- a/Documentation/devicetree/bindings/net/macb.txt
> +++ b/Documentation/devicetree/bindings/net/macb.txt
> @@ -19,6 +19,9 @@ Required properties:
>         Optional elements: 'tx_clk'
>  - clocks: Phandles to input clocks.
>
> +Optional properties:
> +- phy-reset-gpio : Should specify the gpio for phy reset
> +
>  Examples:
>
>         macb0: ethernet@fffc4000 {
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 88c1e1a..e630c56 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -30,6 +30,7 @@
>  #include <linux/of_device.h>
>  #include <linux/of_mdio.h>
>  #include <linux/of_net.h>
> +#include <linux/of_gpio.h>
>
>  #include "macb.h"
>
> @@ -2733,6 +2734,28 @@ static int at91ether_init(struct platform_device *pdev)
>         return 0;
>  }
>
> +#ifdef CONFIG_OF
> +static void macb_reset_phy(struct macb *bp, struct device_node *np, int state)
> +{
> +       if (!np)
> +               return;
> +
> +       bp->reset_gpio = of_get_named_gpio(np, "phy-reset-gpio", 0);

Any reason to do of_get_named() all the time instead of using the one
you stored in bp->reset_gpio?
You could move it to probe and then just use the stored value here ...
not sure if it buys much ;-)

Cheers,

Moritz
