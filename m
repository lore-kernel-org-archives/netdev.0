From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: mdio: of_mdiobus_register(): fall back to
 mdiobus_register() for !CONFIG_OF
Date: Tue, 6 May 2014 10:06:14 -0700
Message-ID: <CAGVrzcZEOLcrzQd=PA+=9PudJQby52F9+8koEZkOESsbSEkuug@mail.gmail.com>
References: <1399395136-12139-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: mugunthanvnm <mugunthanvnm@ti.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f48.google.com ([209.85.216.48]:44125 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbaEFRGz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 13:06:55 -0400
Received: by mail-qa0-f48.google.com with SMTP id i13so4171219qae.35
        for <netdev@vger.kernel.org>; Tue, 06 May 2014 10:06:54 -0700 (PDT)
In-Reply-To: <1399395136-12139-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-05-06 9:52 GMT-07:00 Daniel Mack <zonque@gmail.com>:
> If CONFIG_OF is not set, make of_mdiobus_register() call
> mdiobus_register() instead of returning -ENOSYS.
>
> This way, we can just call of_mdiobus_register() from all DT-enabled
> drivers to handle the compat cases.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> Suggested-by: Florian Fainelli <f.fainelli@gmail.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  include/linux/of_mdio.h | 7 ++++++-
>  1 file changed, 6 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
> index 6fe8464..881a7c3 100644
> --- a/include/linux/of_mdio.h
> +++ b/include/linux/of_mdio.h
> @@ -31,7 +31,12 @@ extern struct mii_bus *of_mdio_find_bus(struct device_node *mdio_np);
>  #else /* CONFIG_OF */
>  static inline int of_mdiobus_register(struct mii_bus *mdio, struct device_node *np)
>  {
> -       return -ENOSYS;
> +       /*
> +        * Fall back to the non-DT function to register a bus.
> +        * This way, we don't have to keep compat bits around in drivers.
> +        */
> +
> +       return mdiobus_register(mdio);
>  }
>
>  static inline struct phy_device *of_phy_find_device(struct device_node *phy_np)
> --
> 1.9.0
>



-- 
Florian
