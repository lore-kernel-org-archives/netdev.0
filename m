From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: unmask link partner capabilities
Date: Fri, 21 Feb 2014 11:24:41 -0800
Message-ID: <CAGVrzcbn104O=4NfjE=WM-z51S0iYijeqw+FBbaBdNGvGV=Tiw@mail.gmail.com>
References: <1392999496-29753-1-git-send-email-cristian.bercaru@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Madalin-Cristian Bucur <madalin.bucur@freescale.com>,
	Shaohui Xie <shaohui.xie@freescale.com>, shruti@freescale.com
To: cristian.bercaru@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:51899 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbaBUTZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Feb 2014 14:25:22 -0500
Received: by mail-pd0-f173.google.com with SMTP id r10so1174041pdi.4
        for <netdev@vger.kernel.org>; Fri, 21 Feb 2014 11:25:21 -0800 (PST)
In-Reply-To: <1392999496-29753-1-git-send-email-cristian.bercaru@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2014-02-21 8:18 GMT-08:00  <cristian.bercaru@freescale.com>:
> From: Cristian Bercaru <cristian.bercaru@freescale.com>
>
> Masking the link partner's capabilities with local capabilities can be
> misleading in autonegotiation scenarios such as PAUSE frame
> autonegotiation.
> Therefore, this patch unmasks the link partner's capabilities.

You have only covered the lpa register here, is lpagb also affected?
It might make sense to cache (lpa & adv) in an intermediate variable
to help clarifiying the checks.

>
> Signed-off-by: Cristian Bercaru <cristian.bercaru@freescale.com>
> ---
>  drivers/net/phy/phy_device.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index a70b604..e57825e6 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -967,8 +967,6 @@ int genphy_read_status(struct phy_device *phydev)
>                 if (adv < 0)
>                         return adv;
>
> -               lpa &= adv;
> -
>                 phydev->speed = SPEED_10;
>                 phydev->duplex = DUPLEX_HALF;
>                 phydev->pause = 0;
> @@ -979,13 +977,13 @@ int genphy_read_status(struct phy_device *phydev)
>
>                         if (lpagb & LPA_1000FULL)
>                                 phydev->duplex = DUPLEX_FULL;
> -               } else if (lpa & (LPA_100FULL | LPA_100HALF)) {
> +               } else if (lpa & adv & (LPA_100FULL | LPA_100HALF)) {
>                         phydev->speed = SPEED_100;
>
> -                       if (lpa & LPA_100FULL)
> +                       if (lpa & adv & LPA_100FULL)
>                                 phydev->duplex = DUPLEX_FULL;
>                 } else
> -                       if (lpa & LPA_10FULL)
> +                       if (lpa & adv & LPA_10FULL)
>                                 phydev->duplex = DUPLEX_FULL;
>
>                 if (phydev->duplex == DUPLEX_FULL) {
> --
> 1.7.11.7
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
