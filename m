From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next RESEND 2/2] net: phy: at803x: use genphy_config_init()
Date: Wed, 16 Apr 2014 12:14:15 -0700
Message-ID: <CAGVrzcYyy7ZTy5=11RQzGMm__xjaQ+479nuoVMMM=cL7d5t34g@mail.gmail.com>
References: <1397661553-22117-1-git-send-email-zonque@gmail.com> <1397661553-22117-2-git-send-email-zonque@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	mugunthanvnm <mugunthanvnm@ti.com>, ujhelyi.m@gmail.com
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f50.google.com ([209.85.216.50]:46264 "EHLO
	mail-qa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756187AbaDPTWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 15:22:25 -0400
Received: by mail-qa0-f50.google.com with SMTP id ih12so10906855qab.23
        for <netdev@vger.kernel.org>; Wed, 16 Apr 2014 12:22:24 -0700 (PDT)
In-Reply-To: <1397661553-22117-2-git-send-email-zonque@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-04-16 8:19 GMT-07:00 Daniel Mack <zonque@gmail.com>:
> Use the generic bits from genphy_config_init() instead of implementing
> the same functionality again.
>
> Signed-off-by: Daniel Mack <zonque@gmail.com>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
> Resending this after 3.15-rc1 has been released, assuming that the
> net-next tree is now open again.
>
>  drivers/net/phy/at803x.c | 36 +++---------------------------------
>  1 file changed, 3 insertions(+), 33 deletions(-)
>
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index bc71947..850171f 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -141,41 +141,11 @@ static int at803x_resume(struct phy_device *phydev)
>
>  static int at803x_config_init(struct phy_device *phydev)
>  {
> -       int val;
>         int ret;
> -       u32 features;
> -
> -       features = SUPPORTED_TP | SUPPORTED_MII | SUPPORTED_AUI |
> -                  SUPPORTED_FIBRE | SUPPORTED_BNC;
> -
> -       val = phy_read(phydev, MII_BMSR);
> -       if (val < 0)
> -               return val;
> -
> -       if (val & BMSR_ANEGCAPABLE)
> -               features |= SUPPORTED_Autoneg;
> -       if (val & BMSR_100FULL)
> -               features |= SUPPORTED_100baseT_Full;
> -       if (val & BMSR_100HALF)
> -               features |= SUPPORTED_100baseT_Half;
> -       if (val & BMSR_10FULL)
> -               features |= SUPPORTED_10baseT_Full;
> -       if (val & BMSR_10HALF)
> -               features |= SUPPORTED_10baseT_Half;
> -
> -       if (val & BMSR_ESTATEN) {
> -               val = phy_read(phydev, MII_ESTATUS);
> -               if (val < 0)
> -                       return val;
> -
> -               if (val & ESTATUS_1000_TFULL)
> -                       features |= SUPPORTED_1000baseT_Full;
> -               if (val & ESTATUS_1000_THALF)
> -                       features |= SUPPORTED_1000baseT_Half;
> -       }
>
> -       phydev->supported = features;
> -       phydev->advertising = features;
> +       ret = genphy_config_init(phydev);
> +       if (ret < 0)
> +               return ret;
>
>         if (phydev->interface == PHY_INTERFACE_MODE_RGMII_TXID) {
>                 ret = phy_write(phydev, AT803X_DEBUG_ADDR,
> --
> 1.9.0
>



-- 
Florian
