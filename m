From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] usbnet: sanitise overlong driver information strings
Date: Thu, 14 Jun 2012 20:08:33 +0100
Message-ID: <1339700913.2719.27.camel@bwh-desktop.uk.solarflarecom.com>
References: <1339672722-22793-1-git-send-email-phil.sutter@viprinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>
To: Phil Sutter <phil.sutter@viprinet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39190 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752265Ab2FNTIg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 15:08:36 -0400
In-Reply-To: <1339672722-22793-1-git-send-email-phil.sutter@viprinet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-06-14 at 13:18 +0200, Phil Sutter wrote:
> As seen on smsc75xx, driver_info->description being longer than 32
> characters messes up 'ethtool -i' output.

I should make ethtool tolerate that, but yes these are supposed to be
null-terminated strings.

Ben.

> Signed-off-by: Phil Sutter <phil.sutter@viprinet.com>
> ---
>  drivers/net/usb/usbnet.c |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 9f58330..d4f7256 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -876,9 +876,9 @@ void usbnet_get_drvinfo (struct net_device *net, struct ethtool_drvinfo *info)
>  {
>  	struct usbnet *dev = netdev_priv(net);
>  
> -	strncpy (info->driver, dev->driver_name, sizeof info->driver);
> -	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
> -	strncpy (info->fw_version, dev->driver_info->description,
> +	strlcpy (info->driver, dev->driver_name, sizeof info->driver);
> +	strlcpy (info->version, DRIVER_VERSION, sizeof info->version);
> +	strlcpy (info->fw_version, dev->driver_info->description,
>  		sizeof info->fw_version);
>  	usb_make_path (dev->udev, info->bus_info, sizeof info->bus_info);
>  }

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
