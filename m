From: Marcel Holtmann <holtmann-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: Re: [PATCH] imwc3200: move iwmc3200 SDIO ids to sdio_ids.h
Date: Tue, 14 Jul 2009 04:14:28 +0200
Message-ID: <1247537668.4549.7.camel@violet>
References: <1247522953-12702-1-git-send-email-tomas.winkler@intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1247522953-12702-1-git-send-email-tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Tomas,

> 1. add intel's sdio vendor id to sdio_ids.h
> 2. move iwmc3200 sdio devices ids to sdio_ids.h

this needs a better commit message since you are touching three
subsystems right now.

Please explain what you are doing. Sounds maybe too obvious, but it is
important that we have clear commit message. Especially when it is
touching more than one subsystem and people have to resolve merge
conflicts.

> This patch is against 2.6.31-rc2
> 7638d5322bd89d49e013a03fe2afaeb6d214fabd

This should not be part of the commit message.

> Cc:inaky.perez-gonzalez-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
> Cc:cindy.h.kao-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
> Cc:samuel.ortiz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
> Cc:yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
> Cc:drzeus-list-p3sGCRWkH8CeZLLa646FqQ@public.gmane.org
> Signed-off-by: Tomas Winkler <tomas.winkler-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/wimax/i2400m/sdio.c          |   10 ++++------
>  drivers/net/wireless/iwmc3200wifi/sdio.c |    4 +++-
>  drivers/net/wireless/iwmc3200wifi/sdio.h |    3 ---
>  include/linux/mmc/sdio_ids.h             |    5 +++++
>  4 files changed, 12 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/wimax/i2400m/sdio.c b/drivers/net/wimax/i2400m/sdio.c
> index 2538825..3dc1990 100644
> --- a/drivers/net/wimax/i2400m/sdio.c
> +++ b/drivers/net/wimax/i2400m/sdio.c
> @@ -58,6 +58,7 @@
>   */
>  
>  #include <linux/debugfs.h>
> +#include <linux/mmc/sdio_ids.h>
>  #include <linux/mmc/sdio.h>
>  #include <linux/mmc/sdio_func.h>
>  #include "i2400m-sdio.h"
> @@ -501,14 +502,11 @@ void i2400ms_remove(struct sdio_func *func)
>  	d_fnend(3, dev, "SDIO func %p\n", func);
>  }
>  
> -enum {
> -	I2400MS_INTEL_VID = 0x89,
> -};
> -
>  static
>  const struct sdio_device_id i2400ms_sdio_ids[] = {
> -	/* Intel: i2400m WiMAX over SDIO */
> -	{ SDIO_DEVICE(I2400MS_INTEL_VID, 0x1402) },
> +	/* Intel: i2400m WiMAX (iwm3200) over SDIO */
> +	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL,
> +	  SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX) },
>  	{ }, 			/* end: all zeroes */

for readability, please indent the SDIO_DEVICE_ID_INTEL...

Otherwise you easily assume you have two SDIO_DEVICE() statement.

>  };
>  MODULE_DEVICE_TABLE(sdio, i2400ms_sdio_ids);
> diff --git a/drivers/net/wireless/iwmc3200wifi/sdio.c b/drivers/net/wireless/iwmc3200wifi/sdio.c
> index 9166818..995a3f6 100644
> --- a/drivers/net/wireless/iwmc3200wifi/sdio.c
> +++ b/drivers/net/wireless/iwmc3200wifi/sdio.c
> @@ -65,6 +65,7 @@
>  #include <linux/kernel.h>
>  #include <linux/netdevice.h>
>  #include <linux/debugfs.h>
> +#include <linux/mmc/sdio_ids.h>
>  #include <linux/mmc/sdio.h>
>  #include <linux/mmc/sdio_func.h>
>  
> @@ -492,7 +493,8 @@ static void iwm_sdio_remove(struct sdio_func *func)
>  }
>  
>  static const struct sdio_device_id iwm_sdio_ids[] = {
> -	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL, SDIO_DEVICE_ID_IWM) },
> +	{ SDIO_DEVICE(SDIO_VENDOR_ID_INTEL,
> +	  SDIO_DEVICE_ID_INTEL_IWMC3200WIFI) },
>  	{ /* end: all zeroes */	},

Same here.

>  };
>  MODULE_DEVICE_TABLE(sdio, iwm_sdio_ids);
> diff --git a/drivers/net/wireless/iwmc3200wifi/sdio.h b/drivers/net/wireless/iwmc3200wifi/sdio.h
> index b3c156b..aab6b68 100644
> --- a/drivers/net/wireless/iwmc3200wifi/sdio.h
> +++ b/drivers/net/wireless/iwmc3200wifi/sdio.h
> @@ -39,9 +39,6 @@
>  #ifndef __IWM_SDIO_H__
>  #define __IWM_SDIO_H__
>  
> -#define SDIO_VENDOR_ID_INTEL 0x89
> -#define SDIO_DEVICE_ID_IWM   0x1403
> -
>  #define IWM_SDIO_DATA_ADDR           0x0
>  #define IWM_SDIO_INTR_ENABLE_ADDR    0x14
>  #define IWM_SDIO_INTR_STATUS_ADDR    0x13
> diff --git a/include/linux/mmc/sdio_ids.h b/include/linux/mmc/sdio_ids.h
> index 39751c8..b46a57a 100644
> --- a/include/linux/mmc/sdio_ids.h
> +++ b/include/linux/mmc/sdio_ids.h
> @@ -22,6 +22,11 @@
>  /*
>   * Vendors and devices.  Sort key: vendor first, device next.
>   */
> +#define SDIO_VENDOR_ID_INTEL			0x0089
> +#define SDIO_DEVICE_ID_INTEL_IWMC3200WIMAX	0x1402
> +#define SDIO_DEVICE_ID_INTEL_IWMC3200WIFI	0x1403
> +#define SDIO_DEVICE_ID_INTEL_IWMC3200TOP        0x1404
> +#define SDIO_DEVICE_ID_INTEL_IWMC3200BT		0x1406

While you are touching files all over, what about GPS?
 
>  #define SDIO_VENDOR_ID_MARVELL			0x02df
>  #define SDIO_DEVICE_ID_MARVELL_LIBERTAS		0x9103

Regards

Marcel


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
