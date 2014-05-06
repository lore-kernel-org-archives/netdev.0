From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: davinci_mdio: Use of_mdiobus_register()
Date: Tue, 6 May 2014 09:42:41 -0700
Message-ID: <CAGVrzcYH2BXTQ7bM_usz=ZuiAoU8PfNWVtDsxb6ONBxEimhDgw@mail.gmail.com>
References: <1399389492-32596-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mugunthanvnm <mugunthanvnm@ti.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f182.google.com ([209.85.216.182]:39788 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750736AbaEFQnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 12:43:22 -0400
Received: by mail-qc0-f182.google.com with SMTP id e16so7226059qcx.27
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 09:43:21 -0700 (PDT)
In-Reply-To: <1399389492-32596-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2014-05-06 8:18 GMT-07:00 Daniel Mack <zonque@gmail.com>:
> of_mdiobus_register() calls mdiobus_register() internally, so the
> functionality is preserved. However, by calling the of_ variant, phy
> nodes can be augmented with extra information.

Are there any non Device Tree aware platforms using this driver?
of_mdiobus_register() is an empty stub returning -ENOSYS when
CONFIG_OF is not set, maybe we should make it return
mdiobus_register() instead...

>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>  drivers/net/ethernet/ti/davinci_mdio.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/ti/davinci_mdio.c b/drivers/net/ethernet/ti/davinci_mdio.c
> index 0cca9de..359d42c 100644
> --- a/drivers/net/ethernet/ti/davinci_mdio.c
> +++ b/drivers/net/ethernet/ti/davinci_mdio.c
> @@ -38,6 +38,7 @@
>  #include <linux/davinci_emac.h>
>  #include <linux/of.h>
>  #include <linux/of_device.h>
> +#include <linux/of_mdio.h>
>  #include <linux/pinctrl/consumer.h>
>
>  /*
> @@ -389,7 +390,7 @@ static int davinci_mdio_probe(struct platform_device *pdev)
>         }
>
>         /* register the mii bus */
> -       ret = mdiobus_register(data->bus);
> +       ret = of_mdiobus_register(data->bus, dev->of_node);
>         if (ret)
>                 goto bail_out;
>
> --
> 1.9.0
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
