From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 3/3] net: phy: bcm-phy-lib: clean up remaining AUXCTL
 register defines
Date: Wed, 25 Jan 2017 08:36:18 -0800
Message-ID: <1439c0db-45df-db8d-df53-e0c4a6385914@gmail.com>
References: <20170125155411.14922-1-zajec5@gmail.com>
 <20170125155411.14922-3-zajec5@gmail.com>
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
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36056 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdAYQgU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 11:36:20 -0500
Received: by mail-pg0-f68.google.com with SMTP id 75so20118130pgf.3
        for <netdev@vger.kernel.org>; Wed, 25 Jan 2017 08:36:20 -0800 (PST)
In-Reply-To: <20170125155411.14922-3-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/25/2017 07:54 AM, Rafał Miłecki wrote:
> From: Rafał Miłecki <rafal@milecki.pl>
> 
> 1) Use 0x%02x format for register number. This follows some other
>    defines and makes it easier to distinct register from values.
> 2) Put register define above values and sort the values. It makes
>    reading header code easier.
> 3) Drop SHDWSEL_ name part from the only value define using it. For all
>    other values we just start with MISC_.

That's not how these bits are defined in the data sheet, so please drop
that part of the patch.

> 
> Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
> ---
>  drivers/net/phy/bcm-phy-lib.c | 6 +++---
>  include/linux/brcmphy.h       | 8 ++++----
>  2 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/phy/bcm-phy-lib.c b/drivers/net/phy/bcm-phy-lib.c
> index ab9ad689617c..8d7e21a9fa77 100644
> --- a/drivers/net/phy/bcm-phy-lib.c
> +++ b/drivers/net/phy/bcm-phy-lib.c
> @@ -241,7 +241,7 @@ int bcm_phy_downshift_get(struct phy_device *phydev, u8 *count)
>  		return val;
>  
>  	/* Check if wirespeed is enabled or not */
> -	if (!(val & MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN)) {
> +	if (!(val & MII_BCM54XX_AUXCTL_MISC_WIRESPEED_EN)) {
>  		*count = DOWNSHIFT_DEV_DISABLE;
>  		return 0;
>  	}
> @@ -283,12 +283,12 @@ int bcm_phy_downshift_set(struct phy_device *phydev, u8 count)
>  	val |= MII_BCM54XX_AUXCTL_MISC_WREN;
>  
>  	if (count == DOWNSHIFT_DEV_DISABLE) {
> -		val &= ~MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN;
> +		val &= ~MII_BCM54XX_AUXCTL_MISC_WIRESPEED_EN;
>  		return bcm54xx_auxctl_write(phydev,
>  					    MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
>  					    val);
>  	} else {
> -		val |= MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN;
> +		val |= MII_BCM54XX_AUXCTL_MISC_WIRESPEED_EN;
>  		ret = bcm54xx_auxctl_write(phydev,
>  					   MII_BCM54XX_AUXCTL_SHDWSEL_MISC,
>  					   val);
> diff --git a/include/linux/brcmphy.h b/include/linux/brcmphy.h
> index bff53da82b58..a79d57caf7f1 100644
> --- a/include/linux/brcmphy.h
> +++ b/include/linux/brcmphy.h
> @@ -104,16 +104,16 @@
>  /*
>   * AUXILIARY CONTROL SHADOW ACCESS REGISTERS.  (PHY REG 0x18)
>   */
> -#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x0000
> +#define MII_BCM54XX_AUXCTL_SHDWSEL_AUXCTL	0x00
>  #define MII_BCM54XX_AUXCTL_ACTL_TX_6DB		0x0400
>  #define MII_BCM54XX_AUXCTL_ACTL_SMDSP_ENA	0x0800
>  
> -#define MII_BCM54XX_AUXCTL_MISC_WREN	0x8000
> +#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC		0x07
> +#define MII_BCM54XX_AUXCTL_MISC_WIRESPEED_EN	0x0010
>  #define MII_BCM54XX_AUXCTL_MISC_RXD_RXC_SKEW	0x0100
>  #define MII_BCM54XX_AUXCTL_MISC_FORCE_AMDIX	0x0200
> -#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC	0x0007
> +#define MII_BCM54XX_AUXCTL_MISC_WREN		0x8000
>  #define MII_BCM54XX_AUXCTL_SHDWSEL_READ_SHIFT	12
> -#define MII_BCM54XX_AUXCTL_SHDWSEL_MISC_WIRESPEED_EN	(1 << 4)
>  
>  #define MII_BCM54XX_AUXCTL_SHDWSEL_MASK	0x0007
>  
> 


-- 
Florian
