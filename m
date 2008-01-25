From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 06/14] [usbnet] Use wlan device name for RNDIS wireless devices
Date: Thu, 24 Jan 2008 16:56:40 -0800
Message-ID: <200801241656.40667.david-b@pacbell.net>
References: <20080120001415.25718.1762.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjd-a1rhEgazXTw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080120001415.25718.1762.stgit-q/85JClnwdg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 19 January 2008, Jussi Kivilinna wrote:
> Use wlan device name for RNDIS wireless devices.
> 
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
> Signed-off-by: Bjorge Dijkstra <bjd-a1rhEgazXTw@public.gmane.org>

Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

> ---
> 
>  drivers/net/usb/usbnet.c |    3 +++
>  drivers/net/usb/usbnet.h |    2 ++
>  2 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 8ed1fc5..a2a2d5e 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1204,6 +1204,9 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
>  		if ((dev->driver_info->flags & FLAG_ETHER) != 0
>  				&& (net->dev_addr [0] & 0x02) == 0)
>  			strcpy (net->name, "eth%d");
> +		/* WLAN devices should always be named "wlan%d" */
> +		if ((dev->driver_info->flags & FLAG_WLAN) != 0)
> +			strcpy(net->name, "wlan%d");
>  
>  		/* maybe the remote can't receive an Ethernet MTU */
>  		if (net->mtu > (dev->hard_mtu - net->hard_header_len))
> diff --git a/drivers/net/usb/usbnet.h b/drivers/net/usb/usbnet.h
> index 1fae434..29ab92e 100644
> --- a/drivers/net/usb/usbnet.h
> +++ b/drivers/net/usb/usbnet.h
> @@ -87,6 +87,8 @@ struct driver_info {
>  #define FLAG_ETHER	0x0020		/* maybe use "eth%d" names */
>  
>  #define FLAG_FRAMING_AX 0x0040		/* AX88772/178 packets */
> +#define FLAG_WLAN	0x0080		/* use "wlan%d" names */
> +
>  
>  	/* init device ... can sleep, or cause probe() failure */
>  	int	(*bind)(struct usbnet *, struct usb_interface *);
> 
