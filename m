From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH v3] net/macb: add support for resetting PHY using GPIO
Date: Wed, 16 Dec 2015 20:10:14 +0100
Message-ID: <6382531.CWmTLTEYMq@wuerfel>
References: <1450290690-32369-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Gregory CLEMENT <gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Nicolas Ferre <nicolas.ferre-AIFe0yeh4nAAvxtiuMwx3w@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Sascha Hauer <s.hauer-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Russell King <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>
To: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1450290690-32369-1-git-send-email-gregory.clement-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 16 December 2015 19:31:30 Gregory CLEMENT wrote:
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
> index 88c1e1a..35661aa 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -28,6 +28,7 @@
>  #include <linux/phy.h>
>  #include <linux/of.h>
>  #include <linux/of_device.h>
> +#include <linux/of_gpio.h>
>  #include <linux/of_mdio.h>
>  #include <linux/of_net.h>

Is this the patch that is already in linux-next?

I needed an additional

#include <linux/gpio/consumer.h>

to avoid this build error on randconfig builds without GPIOLIB:

    drivers/net/ethernet/cadence/macb.c: In function 'macb_probe':
    drivers/net/ethernet/cadence/macb.c:2908:19: error: implicit declaration of function 'devm_gpiod_get_optional' [-Werror=implicit-function-declaration]
      bp->reset_gpio = devm_gpiod_get_optional(&bp->pdev->dev, "phy-reset",
                       ^
    drivers/net/ethernet/cadence/macb.c:2909:8: error: 'GPIOD_OUT_HIGH' undeclared (first use in this function)
            GPIOD_OUT_HIGH);
            ^
    drivers/net/ethernet/cadence/macb.c:2909:8: note: each undeclared identifier is reported only once for each function it appears in
    drivers/net/ethernet/cadence/macb.c: In function 'macb_remove':
    drivers/net/ethernet/cadence/macb.c:2979:3: error: implicit declaration of function 'gpiod_set_value' [-Werror=implicit-function-declaration]


	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
