From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: net/usb/mcs7830: new device IDs
Date: Mon, 28 Jul 2008 15:03:50 -0700
Message-ID: <200807281503.50436.david-b@pacbell.net>
References: <200807282337.19911.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Viktor Horvath <ViktorHorvath-hi6Y0CQ0nG0@public.gmane.org>,
	Robbert Wethmar <robbert-OrSUPh62Yq7z+pZb47iToQ@public.gmane.org>,
	Bart van der Klip <bklip-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200807282337.19911.arnd-r2nGTMty4D4@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Monday 28 July 2008, Arnd Bergmann wrote:
> This adds USB device IDs for MosChip 7730 and Sitecom LN030
> to the mcs7830 driver. The IDs have been reported to work without
> further modifications.
> 
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> Cc: Viktor Horvath <ViktorHorvath-hi6Y0CQ0nG0@public.gmane.org>
> Cc: Robbert Wethmar <robbert-OrSUPh62Yq7z+pZb47iToQ@public.gmane.org>
> Cc: Bart van der Klip <bklip-qWit8jRvyhVmR6Xm/wNWPw@public.gmane.org>

Acked-by: David Brownell <dbrownell-Rn4VEauK+AKRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>

> --- a/drivers/net/usb/mcs7830.c
> +++ b/drivers/net/usb/mcs7830.c
> @@ -46,6 +46,10 @@
>  
>  #define MCS7830_VENDOR_ID	0x9710
>  #define MCS7830_PRODUCT_ID	0x7830
> +#define MCS7730_PRODUCT_ID	0x7730
> +
> +#define SITECOM_VENDOR_ID	0x0DF6
> +#define LN_030_PRODUCT_ID	0x0021
>  
>  #define MCS7830_MII_ADVERTISE	(ADVERTISE_PAUSE_CAP | ADVERTISE_100FULL | \
>  				 ADVERTISE_100HALF | ADVERTISE_10FULL | \
> @@ -491,7 +495,16 @@ static int mcs7830_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>  }
>  
>  static const struct driver_info moschip_info = {
> -	.description	= "MOSCHIP 7830 usb-NET adapter",
> +	.description	= "MOSCHIP 7830/7730 usb-NET adapter",
> +	.bind		= mcs7830_bind,
> +	.rx_fixup	= mcs7830_rx_fixup,
> +	.flags		= FLAG_ETHER,
> +	.in		= 1,
> +	.out		= 2,
> +};
> +
> +static const struct driver_info sitecom_info = {
> +	.description    = "Sitecom LN-30 usb-NET adapter",
>  	.bind		= mcs7830_bind,
>  	.rx_fixup	= mcs7830_rx_fixup,
>  	.flags		= FLAG_ETHER,
> @@ -504,6 +517,14 @@ static const struct usb_device_id products[] = {
>  		USB_DEVICE(MCS7830_VENDOR_ID, MCS7830_PRODUCT_ID),
>  		.driver_info = (unsigned long) &moschip_info,
>  	},
> +	{
> +		USB_DEVICE(MCS7830_VENDOR_ID, MCS7730_PRODUCT_ID),
> +		.driver_info = (unsigned long) &moschip_info,
> +	},
> +	{
> +		USB_DEVICE(SITECOM_VENDOR_ID, LN_030_PRODUCT_ID),
> +		.driver_info = (unsigned long) &sitecom_info,
> +	},
>  	{},
>  };
>  MODULE_DEVICE_TABLE(usb, products);
> 


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
