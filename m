From: Joachim Eastwood <manabian@gmail.com>
Subject: Re: [PATCH v3 10/10] net/macb: add pinctrl consumer support
Date: Tue, 30 Oct 2012 18:37:51 +0100
Message-ID: <CAGhQ9VxJ58ej3j9eEx1rex5h-ua_C53=Z4WwGk5YdjfaYTdHpw@mail.gmail.com>
References: <cover.1351591858.git.nicolas.ferre@atmel.com>
	<3269426bdd44debc00d027651f8248db9d40f3dc.1351591858.git.nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net, havard@skinnemoen.net,
	bhutchings@solarflare.com, linux-arm-kernel@lists.infradead.org,
	plagnioj@jcrosoft.com, patrice.vilchez@atmel.com,
	linux-kernel@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3269426bdd44debc00d027651f8248db9d40f3dc.1351591858.git.nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30 October 2012 11:18, Nicolas Ferre <nicolas.ferre@atmel.com> wrote:
> From: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
>
> If no pinctrl available just report a warning as some architecture may not
> need to do anything.
>
> Signed-off-by: Jean-Christophe PLAGNIOL-VILLARD <plagnioj@jcrosoft.com>
> [nicolas.ferre@atmel.com: adapt the error path]
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: netdev@vger.kernel.org
> ---
>  drivers/net/ethernet/cadence/macb.c | 13 +++++++++++++
>  1 file changed, 13 insertions(+)
>
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 4d51877..eae3d74 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -26,6 +26,9 @@
>  #include <linux/of.h>
>  #include <linux/of_device.h>
>  #include <linux/of_net.h>
> +#include <linux/of_gpio.h>
> +#include <linux/gpio.h>
Why are these two headers added?
I don't see anything from them used in the code added.

Wouldn't the pinctrl header by itself be sufficient?

> +#include <linux/pinctrl/consumer.h>
>
>  #include "macb.h"
>
> @@ -1472,6 +1475,7 @@ static int __init macb_probe(struct platform_device *pdev)
>         struct phy_device *phydev;
>         u32 config;
>         int err = -ENXIO;
> +       struct pinctrl *pinctrl;
>
>         regs = platform_get_resource(pdev, IORESOURCE_MEM, 0);
>         if (!regs) {
> @@ -1479,6 +1483,15 @@ static int __init macb_probe(struct platform_device *pdev)
>                 goto err_out;
>         }
>
> +       pinctrl = devm_pinctrl_get_select_default(&pdev->dev);
> +       if (IS_ERR(pinctrl)) {
> +               err = PTR_ERR(pinctrl);
> +               if (err == -EPROBE_DEFER)
> +                       goto err_out;
> +
> +               dev_warn(&pdev->dev, "No pinctrl provided\n");
> +       }
> +
>         err = -ENOMEM;
>         dev = alloc_etherdev(sizeof(*bp));
>         if (!dev)
> --

regards
Joachim Eastwood
