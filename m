From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: usbnet: fix oops in usbnet_start_xmit
Date: Thu, 6 Sep 2012 05:52:30 -0700
Message-ID: <20120906125230.GI19410@mwanda>
References: <20111109073459.GA14409@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: khlebnikov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20111109073459.GA14409-mgFCXtclrQlZLf2FXnZxJA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I sent this email a year ago when the patch was committed but I
never received a response.

regards,
dan carpenter

On Wed, Nov 09, 2011 at 10:34:59AM +0300, Dan Carpenter wrote:
> Hello Konstantin Khlebnikov,
> 
> This is a semi-automatic email about new static checker warnings.
> 
> The patch 23ba07991dad: "usbnet: fix oops in usbnet_start_xmit" from 
> Nov 7, 2011, leads to the following Smatch complaint:
> 
> drivers/net/usb/usbnet.c +1077 usbnet_start_xmit()
> 	 error: we previously assumed 'skb' could be null (see line 1060)
> 
> drivers/net/usb/usbnet.c
>   1059	
>   1060		if (skb)
>                     ^^^
> check introduced here.
> 
>   1061			skb_tx_timestamp(skb);
>   1062	
>   1063		// some devices want funky USB-level framing, for
>   1064		// win32 driver (usually) and/or hardware quirks
>   1065		if (info->tx_fixup) {
>   1066			skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
>   1067			if (!skb) {
>   1068				if (netif_msg_tx_err(dev)) {
>   1069					netif_dbg(dev, tx_err, dev->net, "can't tx_fixup skb\n");
>   1070					goto drop;
>   1071				} else {
>   1072					/* cdc_ncm collected packet; waits for more */
>   1073					goto not_drop;
>   1074				}
>   1075			}
>   1076		}
>   1077		length = skb->len;
>                          ^^^^^^^^
> dereference without checking.
> 
>   1078	
>   1079		if (!(urb = usb_alloc_urb (0, GFP_ATOMIC))) {
> 
> regards,
> dan carpenter
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
