From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH 2/8] [PATCH] Hardwire CDC descriptors when missing
Date: Sat, 22 Dec 2007 16:49:46 -0800
Message-ID: <20071223004946.55D0822313C@adsl-69-226-248-13.dsl.pltn13.pacbell.net>
References: <11983602942818-git-send-email-bjd@jooz.net>
 <11983602953487-git-send-email-bjd@jooz.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: bjd@jooz.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp123.sbc.mail.sp1.yahoo.com ([69.147.64.96]:44060 "HELO
	smtp123.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753199AbXLWAtr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2007 19:49:47 -0500
In-Reply-To: <11983602953487-git-send-email-bjd@jooz.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From bjd@jooz.net  Sat Dec 22 13:53:00 2007
> X-SourceIP: 213.93.131.145
> From: Bjorge Dijkstra <bjd@jooz.net>
> To: dbrownell@users.sourceforge.net
> Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
> Subject: [PATCH 2/8] [PATCH] Hardwire CDC descriptors when missing
> Date: Sat, 22 Dec 2007 22:51:28 +0100
>
> Just as ActiveSync devices, some regular RNDIS devices also lack
> the CDC descriptors (e.g. devices based on BCM4320 WLAN chip).
> This patch hardwires the CDC descriptors for all RNDIS style devices
> when they are missing.
>
> Signed-off-by: Bjorge Dijkstra <bjd@jooz.net>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

Note what this tells us about how little Microsoft cares about
the interoperability specs they claim to conform to.  Having
those descriptors is *NOT* optional in their (incomplete and
in adequate) RNDIS specification.  (I've not seen ActiveSync
specs, so that support is pure guesswork.)


> ---
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
> -?
>  /*-------------------------------------------------------------------------
>   *
>   * Communications Device Class, Ethernet Control model
> -- 
> 1.5.2.5
>
