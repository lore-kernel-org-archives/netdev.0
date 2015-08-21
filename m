From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 2/2] lan78xx: update eee code
Date: Fri, 21 Aug 2015 14:56:35 -0700
Message-ID: <55D79E93.8040404@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D5480D9@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Woojung.Huh@microchip.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34160 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbbHUV67 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2015 17:58:59 -0400
Received: by pdbfa8 with SMTP id fa8so30782563pdb.1
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2015 14:58:59 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D5480D9@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 21/08/15 14:41, Woojung.Huh@microchip.com wrote:
> Patch to pdate EEE code.

This really deserves a better explanation of what is it that you are
fixing here.

> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>
> ---
>  drivers/net/usb/lan78xx.c | 44 ++++++++++++++++++++++++--------------------
>  drivers/net/usb/lan78xx.h | 22 +++++++++++-----------
>  2 files changed, 35 insertions(+), 31 deletions(-)
> 
> diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
> index 4bcbf28..af102b0 100644
> --- a/drivers/net/usb/lan78xx.c
> +++ b/drivers/net/usb/lan78xx.c
> @@ -1296,38 +1296,37 @@ static int lan78xx_get_eee(struct net_device *net, struct ethtool_eee *edata)
>  	if (ret < 0)
>  		return ret;
>  
> +	buf = lan78xx_mmd_read(dev->net, dev->mii.phy_id,
> +			       PHY_MMD_DEV_7, PHY_EEE_ADVERTISEMENT);
> +	adv = mmd_eee_adv_to_ethtool_adv_t(buf);
> +	buf = lan78xx_mmd_read(dev->net, dev->mii.phy_id,
> +			       PHY_MMD_DEV_7, PHY_EEE_LP_ADVERTISEMENT);
> +	lpadv = mmd_eee_adv_to_ethtool_adv_t(buf);

Considering your function signatures, it sounds like you should
implement a libphy driver and you could get things like phy_init_eee()
for free.

[snip]

>  	/* enable PHY interrupts */
>  	ret = lan78xx_read_reg(dev, INT_EP_CTL, &buf);
>  	buf |= INT_ENP_PHY_INT;
> diff --git a/drivers/net/usb/lan78xx.h b/drivers/net/usb/lan78xx.h
> index ae7562e..95e721b 100644
> --- a/drivers/net/usb/lan78xx.h
> +++ b/drivers/net/usb/lan78xx.h
> @@ -1047,23 +1047,23 @@
>  #define PHY_MMD_DEV_3				3
>  
>  #define PHY_EEE_PCS_STATUS			(0x1)
> -#define PHY_EEE_PCS_STATUS_TX_LPI_RCVD_		((WORD)0x0800)
> -#define PHY_EEE_PCS_STATUS_RX_LPI_RCVD_		((WORD)0x0400)
> -#define PHY_EEE_PCS_STATUS_TX_LPI_IND_		((WORD)0x0200)
> -#define PHY_EEE_PCS_STATUS_RX_LPI_IND_		((WORD)0x0100)
> -#define PHY_EEE_PCS_STATUS_PCS_RCV_LNK_STS_	((WORD)0x0004)
> +#define PHY_EEE_PCS_STATUS_TX_LPI_RCVD_		(0x0800)
> +#define PHY_EEE_PCS_STATUS_RX_LPI_RCVD_		(0x0400)
> +#define PHY_EEE_PCS_STATUS_TX_LPI_IND_		(0x0200)
> +#define PHY_EEE_PCS_STATUS_RX_LPI_IND_		(0x0100)
> +#define PHY_EEE_PCS_STATUS_PCS_RCV_LNK_STS_	(0x0004)

Can you look at updating include/uapi/linux/mdio.h with the missing
registers for your use case instead of replicating this in a driver?
-- 
Florian
