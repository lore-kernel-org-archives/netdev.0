From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/8] b44: rename B44_PHY_ADDR_NO_PHY to
 B44_PHY_ADDR_NO_LOCAL_PHY
Date: Mon, 16 Dec 2013 15:51:45 +0000
Message-ID: <1387209105.1799.27.camel@bwh-desktop.uk.level5networks.com>
References: <1387132925-18651-1-git-send-email-hauke@hauke-m.de>
	 <1387132925-18651-3-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <zambrano@broadcom.com>,
	<netdev@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:33166 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754143Ab3LPPvu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 10:51:50 -0500
In-Reply-To: <1387132925-18651-3-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-12-15 at 19:41 +0100, Hauke Mehrtens wrote:
> The PHY address 30 means there is no local PHY, but there could be an
> external PHY like a switch connected via MII. This is the case on most
> embedded home routers where this driver is used.
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
>  	/* do a phy reset to test if there is an active phy */
>  	if (b44_phy_reset(bp) < 0)
> -		bp->phy_addr = B44_PHY_ADDR_NO_PHY;
> +		bp->phy_addr = B44_PHY_ADDR_NO_LOACL_PHY;

LOACL?

>  	netdev_info(dev, "%s %pM\n", DRV_DESCRIPTION, dev->dev_addr);
>  
> diff --git a/drivers/net/ethernet/broadcom/b44.h b/drivers/net/ethernet/broadcom/b44.h
> index 8ed7d6b..ade80d6 100644
> --- a/drivers/net/ethernet/broadcom/b44.h
> +++ b/drivers/net/ethernet/broadcom/b44.h
> @@ -280,9 +280,9 @@ struct ring_info {
>  	dma_addr_t	mapping;
>  };
>  
> -#define B44_MCAST_TABLE_SIZE	32
> -#define B44_PHY_ADDR_NO_PHY	30
> -#define B44_MDC_RATIO		5000000
> +#define B44_MCAST_TABLE_SIZE		32
> +#define B44_PHY_ADDR_NO_LOACL_PHY	30 /* no local phy regs */
> +#define B44_MDC_RATIO			5000000
>  
>  #define	B44_STAT_REG_DECLARE		\
>  	_B44(tx_good_octets)		\

At least it's spelt consistently wrongly. :-)

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
