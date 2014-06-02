From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2 1/2] libphy: Add phy specific function to access
 mmd phy registers
Date: Mon, 02 Jun 2014 14:12:41 -0700 (PDT)
Message-ID: <20140602.141241.2078113558597319616.davem@davemloft.net>
References: <1401380913-4207-1-git-send-email-vbridgers2013@gmail.com>
	<1401380913-4207-2-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: vbridgers2013@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932171AbaFBVMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2014 17:12:42 -0400
In-Reply-To: <1401380913-4207-2-git-send-email-vbridgers2013@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vince Bridgers <vbridgers2013@gmail.com>
Date: Thu, 29 May 2014 11:28:32 -0500

> -		eee_cap = phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_ABLE,
> -						MDIO_MMD_PCS, phydev->addr);
> +		eee_cap = phydrv->rd_mmd_indirect(phydev, MDIO_PCS_EEE_ABLE,
> +						  MDIO_MMD_PCS, phydev->addr);
> +
 ...
>  		 */
> -		eee_lp = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_LPABLE,
> -					       MDIO_MMD_AN, phydev->addr);
> +		eee_lp = phydrv->rd_mmd_indirect(phydev, MDIO_AN_EEE_LPABLE,
> +						 MDIO_MMD_AN, phydev->addr);
 ...
> -		eee_adv = phy_read_mmd_indirect(phydev->bus, MDIO_AN_EEE_ADV,
> -						MDIO_MMD_AN, phydev->addr);
> +		eee_adv = phydrv->rd_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
> +						  MDIO_MMD_AN, phydev->addr);

In the case above you properly adjusted the argument indentation.

But, in the cases below, you did not.  Please fix this up.

> @@ -1029,14 +1031,14 @@ int phy_init_eee(struct phy_device *phydev, bool clk_stop_enable)
>  			/* Configure the PHY to stop receiving xMII
>  			 * clock while it is signaling LPI.
>  			 */
> -			int val = phy_read_mmd_indirect(phydev->bus, MDIO_CTRL1,
> +			int val = phydrv->rd_mmd_indirect(phydev, MDIO_CTRL1,
>  							MDIO_MMD_PCS,
>  							phydev->addr);
 ...
> @@ -1056,7 +1058,7 @@ EXPORT_SYMBOL(phy_init_eee);
>   */
>  int phy_get_eee_err(struct phy_device *phydev)
>  {
> -	return phy_read_mmd_indirect(phydev->bus, MDIO_PCS_EEE_WK_ERR,
> +	return phydev->drv->rd_mmd_indirect(phydev, MDIO_PCS_EEE_WK_ERR,
>  				     MDIO_MMD_PCS, phydev->addr);
 ...
> +int gen_rd_mmd_indirect(struct phy_device *phydev, int prtad, int devad,
> +			int addr);
> +void gen_wr_mmd_indirect(struct phy_device *phydev, int prtad, int devad,
> +			 int addr, u32 data);

Thanks.
