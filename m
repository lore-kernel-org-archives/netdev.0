From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 2/3] net: phy: broadcom: drop duplicated define for RXD to
 RXC delay
Date: Wed, 25 Jan 2017 08:36:06 -0800
Message-ID: <18b7733b-725e-6312-3011-2e1eacfc6164@gmail.com>
References: <20170125155411.14922-1-zajec5@gmail.com>
 <20170125155411.14922-2-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Xo Wang <xow@google.com>, Joel Stanley <joel@jms.id.au>,
        Jon Mason <jon.mason@broadcom.com>,
        Jaedon Shin <jaedon.shin@gmail.com>, netdev@vger.kernel.org,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <rafal@milecki.pl>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34318 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751656AbdAYQg2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 11:36:28 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so2367140pgj.1
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 08:36:28 -0800 (PST)
In-Reply-To: <20170125155411.14922-2-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2017 07:54 AM, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> We had two defines for the same bit (both were used with the
> MII_BCM54XX_AUXCTL_SHDWSEL_MISC register).
> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
> ---
>  drivers/net/phy/broadcom.c | 2 +-
>  include/linux/brcmphy.h    | 1 -
>  2 files changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/drivers/net/phy/broadcom.c b/drivers/net/phy/broadcom.c
> index 25c6e6cea2dc..9b7c2d57ca92 100644
> --- a/drivers/net/phy/broadcom.c
> +++ b/drivers/net/phy/broadcom.c
> @@ -42,7 +42,7 @@ static int bcm54810_config(struct phy_device *phydev)
>  		return rc;
>  
>  	val = bcm54xx_auxctl_read(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC);
> -	val &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN;
> +	val &= ~MII_BCM54XX_AUXCTL_MISC_RXD_RXC_SKEW;
>  	val |= MII_BCM54XX_AUXCTL_MISC_WREN;
>  	rc = bcm54xx_auxctl_write(phydev, MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
>  				  val);
> diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
> index 34e61004b9dc..bff53da82b58 100644
> --- a/include/linux/brcmphy.h
> +++ b/include/linux/brcmphy.h
> @@ -113,7 +113,6 @@
>  #define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX	0x0200
>  #define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
>  #define MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT	12
> -#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC_RGMII_SKEW_EN	(1 << 8)
>  #define MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN	(1 << 4)

Please drop the other one and keep this one instead, the SHDWSEL prefix
is intentional and correct here since it matches the datasheet.
-- 
Florian
