From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] phylib: use MDIO_DEVS[12]
Date: Fri, 22 Aug 2014 13:41:38 -0700
Message-ID: <CAGVrzcbXd-AJVn3oSPmN7m1+CFyJ_EsswtEYioUKbwzpPBMy0g@mail.gmail.com>
References: <1920521.UOn8o4CGAS@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f178.google.com ([209.85.223.178]:41201 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbaHVUmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 16:42:19 -0400
Received: by mail-ie0-f178.google.com with SMTP id rd18so7176926iec.9
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 13:42:18 -0700 (PDT)
In-Reply-To: <1920521.UOn8o4CGAS@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-08-22 12:56 GMT-07:00 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>:
> The bare register numbers are used despite <uapi/linux/mdio.h> has MDIO_DEVS[12]
> #define'd for those.
>
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>

>
> ---
> This patch is against DaveM's 'net-next.git' repo.
>
>  drivers/net/phy/phy_device.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> Index: net-next/drivers/net/phy/phy_device.c
> ===================================================================
> --- net-next.orig/drivers/net/phy/phy_device.c
> +++ net-next/drivers/net/phy/phy_device.c
> @@ -230,13 +230,13 @@ static int get_phy_c45_ids(struct mii_bu
>         for (i = 1;
>              i < num_ids && c45_ids->devices_in_package == 0;
>              i++) {
> -               reg_addr = MII_ADDR_C45 | i << 16 | 6;
> +               reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS2;
>                 phy_reg = mdiobus_read(bus, addr, reg_addr);
>                 if (phy_reg < 0)
>                         return -EIO;
>                 c45_ids->devices_in_package = (phy_reg & 0xffff) << 16;
>
> -               reg_addr = MII_ADDR_C45 | i << 16 | 5;
> +               reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS1;
>                 phy_reg = mdiobus_read(bus, addr, reg_addr);
>                 if (phy_reg < 0)
>                         return -EIO;
>



-- 
Florian
