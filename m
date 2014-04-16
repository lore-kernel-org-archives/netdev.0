From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RESEND 1/2] net: phy: export genphy_config_init()
Date: Wed, 16 Apr 2014 12:14:03 -0700
Message-ID: <CAGVrzcbwRod-YSXKJ1hgd81SaPHkB7mEMWFZbEa1yaBUU-134A@mail.gmail.com>
References: <1397661553-22117-1-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	mugunthanvnm <mugunthanvnm@ti.com>, ujhelyi.m@gmail.com
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f49.google.com ([209.85.216.49]:45157 "EHLO
	mail-qa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606AbaDPTOn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 15:14:43 -0400
Received: by mail-qa0-f49.google.com with SMTP id j7so11032892qaq.36
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 12:14:43 -0700 (PDT)
In-Reply-To: <1397661553-22117-1-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-16 8:19 GMT-07:00 Daniel Mack <zonque@gmail.com>:
> This enables other drivers to call this generic implementation, and then
> only do specific details on top of it.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
> Resending this after 3.15-rc1 has been released, assuming that the
> net-next tree is now open again.
>
>  drivers/net/phy/phy_device.c | 3 ++-
>  include/linux/phy.h          | 1 +
>  2 files changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 2f6989b..84485ea 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -1029,7 +1029,7 @@ static int gen10g_read_status(struct phy_device *phydev)
>         return 0;
>  }
>
> -static int genphy_config_init(struct phy_device *phydev)
> +int genphy_config_init(struct phy_device *phydev)
>  {
>         int val;
>         u32 features;
> @@ -1074,6 +1074,7 @@ static int genphy_config_init(struct phy_device *phydev)
>
>         return 0;
>  }
> +EXPORT_SYMBOL(genphy_config_init);
>
>  static int gen10g_config_init(struct phy_device *phydev)
>  {
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 565188c..dcf7f13 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -609,6 +609,7 @@ static inline int phy_read_status(struct phy_device *phydev)
>         return phydev->drv->read_status(phydev);
>  }
>
> +int genphy_config_init(struct phy_device *phydev);
>  int genphy_setup_forced(struct phy_device *phydev);
>  int genphy_restart_aneg(struct phy_device *phydev);
>  int genphy_config_aneg(struct phy_device *phydev);
> --
> 1.9.0
>



-- 
Florian
