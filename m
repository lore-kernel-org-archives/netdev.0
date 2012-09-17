From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ncm: allow for NULL terminations
Date: Mon, 17 Sep 2012 16:45:24 +0100
Message-ID: <1347896724.2685.2.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120917105853.30298.29234.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36465 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932238Ab2IQPp2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Sep 2012 11:45:28 -0400
In-Reply-To: <20120917105853.30298.29234.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-09-17 at 11:58 +0100, Alan Cox wrote:
> From: Alan Cox <alan@linux.intel.com>
> 
> The strings are passed to snprintf so must be null terminated. It seems the
> copy length is incorrectly set.

Please use strlcpy() instead.  (I thought someone had already gone round
the get_drvinfo implementations and fixed them to do that, actually.)

Ben.

> Signed-off-by: Alan Cox <alan@linux.intel.com>
> ---
> 
>  drivers/net/usb/cdc_ncm.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
> index 4cd582a..af8cce7 100644
> --- a/drivers/net/usb/cdc_ncm.c
> +++ b/drivers/net/usb/cdc_ncm.c
> @@ -145,10 +145,10 @@ cdc_ncm_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
>  {
>  	struct usbnet *dev = netdev_priv(net);
>  
> -	strncpy(info->driver, dev->driver_name, sizeof(info->driver));
> -	strncpy(info->version, DRIVER_VERSION, sizeof(info->version));
> +	strncpy(info->driver, dev->driver_name, sizeof(info->driver) - 1);
> +	strncpy(info->version, DRIVER_VERSION, sizeof(info->version) - 1);
>  	strncpy(info->fw_version, dev->driver_info->description,
> -		sizeof(info->fw_version));
> +		sizeof(info->fw_version) - 1);
>  	usb_make_path(dev->udev, info->bus_info, sizeof(info->bus_info));
>  }
>  
> 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
