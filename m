From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2 1/2] phylib: Convert MDIO and PHY Lib drivers to
 support 10G
Date: Fri, 21 May 2010 19:55:25 +0100
Message-ID: <1274468125.2089.4.camel@achroite.uk.solarflarecom.com>
References: <1274466711-24962-1-git-send-email-afleming@freescale.com>
	 <1274466711-24962-2-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:54698 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab0EUSz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 14:55:29 -0400
In-Reply-To: <1274466711-24962-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-05-21 at 13:31 -0500, Andy Fleming wrote:
[...]
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 1a99bb2..c72ba85 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
[...]
> @@ -873,6 +941,36 @@ static int genphy_config_init(struct phy_device *phydev)
>  
>  	return 0;
>  }
> +
> +/* Replicate mdio45_probe */
> +int gen10g_config_init(struct phy_device *phydev)
> +{
> +	int mmd, stat2, devs1, devs2;
> +
> +	phydev->supported = phydev->advertising = SUPPORTED_10000baseT_Full;
[...]

Whyever are you assuming that?

> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 987e111..8fb1b52 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
[...]
> @@ -62,7 +63,8 @@ typedef enum {
>  	PHY_INTERFACE_MODE_RGMII_ID,
>  	PHY_INTERFACE_MODE_RGMII_RXID,
>  	PHY_INTERFACE_MODE_RGMII_TXID,
> -	PHY_INTERFACE_MODE_RTBI
> +	PHY_INTERFACE_MODE_RTBI,
> +	PHY_INTERFACE_MODE_XGMII
>  } phy_interface_t;
[...]

What about XAUI and XFI?  I don't think anyone uses XGMII other than as
an on-chip interface.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

