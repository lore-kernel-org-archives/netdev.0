From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/3] net: phylib: add adjust_state callback to phy device
Date: Wed, 4 Jun 2014 22:11:29 -0700
Message-ID: <CAGVrzcYfa6rwhqpZ8NB9Za0WdJDi3eePoYLcHsqQnUhuP3ui=w@mail.gmail.com>
References: <1401872439-30107-1-git-send-email-zonque@gmail.com> <1401872439-30107-2-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, marek.belisko@gmail.com,
	Matus Ujhelyi <ujhelyi.m@gmail.com>
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f50.google.com ([209.85.192.50]:54251 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbaFEFMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 01:12:10 -0400
Received: by mail-qg0-f50.google.com with SMTP id z60so769484qgd.23
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 22:12:09 -0700 (PDT)
In-Reply-To: <1401872439-30107-2-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-06-04 2:00 GMT-07:00 Daniel Mack <zonque@gmail.com>:
> Allow phy drivers to take action when the core does its link adjustment.
> No change for drivers that do not implement this callback.

This sounds potentially dangerous if misused, PHY drivers would
basically be allowed to do arbitrary link state changes based on their
custom needs. I really need to review your workaround here to better
understand whether we can come up with a solution that allows for less
liberty in PHY drivers.

Thanks

>
> Signed-off-by: Daniel Mack <zonque@gmail.com>
> ---
>  drivers/net/phy/phy.c | 3 +++
>  include/linux/phy.h   | 3 +++
>  2 files changed, 6 insertions(+)
>
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 3bc079a..f9c5577 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -720,6 +720,9 @@ void phy_state_machine(struct work_struct *work)
>
>         mutex_lock(&phydev->lock);
>
> +       if (phydev->drv->adjust_state)
> +               phydev->drv->adjust_state(phydev);
> +
>         switch (phydev->state) {
>         case PHY_DOWN:
>         case PHY_STARTING:
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 51d15f6..27cbdf4 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -529,6 +529,9 @@ struct phy_driver {
>         /* See set_wol, but for checking whether Wake on LAN is enabled. */
>         void (*get_wol)(struct phy_device *dev, struct ethtool_wolinfo *wol);
>
> +       /* Called when the PHY core adjusts the link of a PHY device */
> +       void (*adjust_state)(struct phy_device *dev);
> +
>         struct device_driver driver;
>  };
>  #define to_phy_driver(d) container_of(d, struct phy_driver, driver)
> --
> 1.9.3
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
