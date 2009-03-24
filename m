From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: Re: [PATCH 3/3] smsc911x: add flag SMSC911X_USE_INTERPHY
Date: Tue, 24 Mar 2009 08:51:05 +0100
Message-ID: <20090324075105.GE25436@pengutronix.de>
References: <4e090d470903232347g2b6e91a7o385af2e66f05a936@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org,
	linux-arm-kernel@lists.arm.linux.org.uk, kernel@pengutronix.de
To: Richard Zhao <linuxzsc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:58704 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbZCXHvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 03:51:32 -0400
Content-Disposition: inline
In-Reply-To: <4e090d470903232347g2b6e91a7o385af2e66f05a936@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Richard,

On Tue, Mar 24, 2009 at 02:47:25PM +0800, Richard Zhao wrote:
> mx31pdk board don't have external PHY, but it wrongly pull up MDIO.
> So, add flag SMSC911X_USE_INTERPHY to force using internal PHY.

This patch is outdated. Linux-next already contains a
SMSC911X_FORCE_INTERNAL_PHY for exactly this reason.

Sascha

> 
> Signed-off-by: Richard Zhao <linuxzsc@gmail.com>
> 
> diff --git a/drivers/net/smsc911x.c b/drivers/net/smsc911x.c
> index d1590ac..60f7b74 100644
> --- a/drivers/net/smsc911x.c
> +++ b/drivers/net/smsc911x.c
> @@ -831,10 +831,12 @@ static int __devinit smsc911x_mii_init(struct
> platform_device *pdev,
>  	case 0x01150000:
>  	case 0x117A0000:
>  	case 0x115A0000:
> -		/* External PHY supported, try to autodetect */
> -		if (smsc911x_phy_initialise_external(pdata) < 0) {
> -			SMSC_TRACE(HW, "No external PHY detected, "
> -				"using internal PHY");
> +		if (!(pdata->config & SMSC911X_USE_INTERPHY)) {
> +			/* External PHY supported, try to autodetect */
> +			if (smsc911x_phy_initialise_external(pdata) < 0) {
> +				SMSC_TRACE(HW, "No external PHY detected, "
> +					"using internal PHY");
> +			}
>  		}
>  		break;
>  	default:
> diff --git a/include/linux/smsc911x.h b/include/linux/smsc911x.h
> index 1cbf031..42b088d 100644
> --- a/include/linux/smsc911x.h
> +++ b/include/linux/smsc911x.h
> @@ -43,5 +43,6 @@ struct smsc911x_platform_config {
>  /* Constants for flags */
>  #define SMSC911X_USE_16BIT 			(BIT(0))
>  #define SMSC911X_USE_32BIT 			(BIT(1))
> +#define SMSC911X_USE_INTERPHY 			(BIT(2))
> 
>  #endif /* __LINUX_SMSC911X_H__ */
> -- 
> 1.5.6.3
> 

-- 
Pengutronix e.K.                           |                             |
Industrial Linux Solutions                 | http://www.pengutronix.de/  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0    |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-5555 |
