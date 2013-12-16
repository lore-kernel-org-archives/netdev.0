From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/8] b44: rename B44_PHY_ADDR_NO_PHY to B44_PHY_ADDR_NO_LOCAL_PHY
Date: Mon, 16 Dec 2013 10:40:35 -0800
Message-ID: <CAGVrzcb0gZxpyiRNAi48u8MnCRzwBDO3HwpTPPWYkuMdQe5q_w@mail.gmail.com>
References: <1387132925-18651-1-git-send-email-hauke@hauke-m.de> <1387132925-18651-3-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, zambrano@broadcom.com,
	netdev <netdev@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:40145 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754640Ab3LPSlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 13:41:16 -0500
Received: by mail-pa0-f46.google.com with SMTP id kl14so3289905pab.5
        for <netdev@vger.kernel.org>; Mon, 16 Dec 2013 10:41:16 -0800 (PST)
In-Reply-To: <1387132925-18651-3-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2013/12/15 Hauke Mehrtens <hauke@hauke-m.de>:
> The PHY address 30 means there is no local PHY, but there could be an
> external PHY like a switch connected via MII. This is the case on most
> embedded home routers where this driver is used.

Looking at this some more, I do not think the b44 driver was always
clear that (at least in  Broadcom terminology):

- address 0 is a "special" broadcast MDIO address to make Roboswitch
devices act as standard PHYs such that you could read the MII_PHYSID1
and MII_PHYSID2 registers and determine if that is a switch or a PHY
- address 30 is the switch pseudo-PHY address through which all
switch-specifc settings must be routed from/to

So saying that address 30 means no "external PHY" is sort of correct,
although not quite. Hopefully the remaining patches try to remove that
ambiguity.

>
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>  drivers/net/ethernet/broadcom/b44.c |    2 +-
>  drivers/net/ethernet/broadcom/b44.h |    6 +++---
>  2 files changed, 4 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
> index 3c7909e..fce36dd 100644
> --- a/drivers/net/ethernet/broadcom/b44.c
> +++ b/drivers/net/ethernet/broadcom/b44.c
> @@ -2237,7 +2237,7 @@ static int b44_init_one(struct ssb_device *sdev,
>
>         /* do a phy reset to test if there is an active phy */
>         if (b44_phy_reset(bp) < 0)
> -               bp->phy_addr = B44_PHY_ADDR_NO_PHY;
> +               bp->phy_addr = B44_PHY_ADDR_NO_LOACL_PHY;
>
>         netdev_info(dev, "%s %pM\n", DRV_DESCRIPTION, dev->dev_addr);
>
> diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
> index 8ed7d6b..ade80d6 100644
> --- a/drivers/net/ethernet/broadcom/b44.h
> +++ b/drivers/net/ethernet/broadcom/b44.h
> @@ -280,9 +280,9 @@ struct ring_info {
>         dma_addr_t      mapping;
>  };
>
> -#define B44_MCAST_TABLE_SIZE   32
> -#define B44_PHY_ADDR_NO_PHY    30
> -#define B44_MDC_RATIO          5000000
> +#define B44_MCAST_TABLE_SIZE           32
> +#define B44_PHY_ADDR_NO_LOACL_PHY      30 /* no local phy regs */
> +#define B44_MDC_RATIO                  5000000
>
>  #define        B44_STAT_REG_DECLARE            \
>         _B44(tx_good_octets)            \
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



-- 
Florian
