From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 02/14] [cdc_ether] Hardwire CDC descriptors when missing
Date: Thu, 24 Jan 2008 16:55:00 -0800
Message-ID: <200801241655.00553.david-b@pacbell.net>
References: <20080120001353.25718.38880.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, bjd@jooz.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:36359 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753974AbYAYBUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 20:20:19 -0500
In-Reply-To: <20080120001353.25718.38880.stgit@fate.lan>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 January 2008, Jussi Kivilinna wrote:
> From: Bjorge Dijkstra <bjd@jooz.net>
> 
> Just as ActiveSync devices, some regular RNDIS devices also lack
> the CDC descriptors (e.g. devices based on BCM4320 WLAN chip).
> This patch hardwires the CDC descriptors for all RNDIS style devices
> when they are missing.
> 
> Signed-off-by: Bjorge Dijkstra <bjd@jooz.net>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

> ---
> 
>  drivers/net/usb/cdc_ether.c |   10 +++++-----
>  1 files changed, 5 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
> index a42acc3..97c17bb 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -228,15 +228,16 @@ next_desc:
>  		buf += buf [0];
>  	}
>  
> -	/* Microsoft ActiveSync based RNDIS devices lack the CDC descriptors,
> -	 * so we'll hard-wire the interfaces and not check for descriptors.
> +	/* Microsoft ActiveSync based and some regular RNDIS devices lack the
> +	 * CDC descriptors, so we'll hard-wire the interfaces and not check
> +	 * for descriptors.
>  	 */
> -	if (is_activesync(&intf->cur_altsetting->desc) && !info->u) {
> +	if (rndis && !info->u) {
>  		info->control = usb_ifnum_to_if(dev->udev, 0);
>  		info->data = usb_ifnum_to_if(dev->udev, 1);
>  		if (!info->control || !info->data) {
>  			dev_dbg(&intf->dev,
> -				"activesync: master #0/%p slave #1/%p\n",
> +				"rndis: master #0/%p slave #1/%p\n",
>  				info->control,
>  				info->data);
>  			goto bad_desc;
> @@ -316,7 +317,6 @@ void usbnet_cdc_unbind(struct usbnet *dev, struct usb_interface *intf)
>  }
>  EXPORT_SYMBOL_GPL(usbnet_cdc_unbind);
>  
> -
>  /*-------------------------------------------------------------------------
>   *
>   * Communications Device Class, Ethernet Control model
> 


