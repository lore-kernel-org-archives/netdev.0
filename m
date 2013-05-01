From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] usb: add device IDs for Dell 5804 (Novatel E371) WWAN
 card
Date: Wed, 01 May 2013 15:24:04 -0500
Message-ID: <1367439844.12353.21.camel@dcbw.foobar.com>
References: <1367431305.12353.8.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	Network Development <netdev@vger.kernel.org>,
	Greg KH <gregkh@linuxfoundation.org>, stable@vger.kernel.org,
	Matthias Urlichs <smurf@smurf.noris.de>, dagofthedofg@gmail.com
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29639 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757053Ab3EAUWB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 16:22:01 -0400
In-Reply-To: <1367431305.12353.8.camel@dcbw.foobar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-01 at 13:01 -0500, Dan Williams wrote:
> A rebranded Novatel E371 for AT&T's LTE bands.
> 
> Cc: <stable@vger.kernel.org>
> Signed-off-by: Dan Williams <dcbw@redhat.com>

Skip this patch as I'll split it up, and it's also whitespace damaged to
to an Evolution issue I'm sorting out.  Will resubmit only the net part
to netdev, and only the USB part to linux-usb.

Dan

> ---
> See https://bugzilla.redhat.com/show_bug.cgi?id=955426
> 
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
> index 57136dc..299c53b 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -615,6 +615,13 @@ static const struct usb_device_id	products [] = {
>  	.driver_info = 0,
>  },
>  
> +/* Dell Wireless 5804 (Novatel E371) - handled by qmi_wwan */
> +{
> +	USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, 0x819b, USB_CLASS_COMM,
> +			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
> +	.driver_info = 0,
> +},
> +
>  /* AnyDATA ADU960S - handled by qmi_wwan */
>  {
>  	USB_DEVICE_AND_INTERFACE_INFO(0x16d5, 0x650a, USB_CLASS_COMM,
> diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
> index 968d5d5..38734fd 100644
> --- a/drivers/net/usb/qmi_wwan.c
> +++ b/drivers/net/usb/qmi_wwan.c
> @@ -392,6 +392,13 @@ static const struct usb_device_id products[] = {
>  					      USB_CDC_PROTO_NONE),
>  		.driver_info        = (unsigned long)&qmi_wwan_info,
>  	},
> +	{	/* Dell Wireless 5804 (Novatel E371) */
> +		USB_DEVICE_AND_INTERFACE_INFO(0x413C, 0x819b,
> +					      USB_CLASS_COMM,
> +					      USB_CDC_SUBCLASS_ETHERNET,
> +					      USB_CDC_PROTO_NONE),
> +		.driver_info        = (unsigned long)&qmi_wwan_info,
> +	},
>  	{	/* ADU960S */
>  		USB_DEVICE_AND_INTERFACE_INFO(0x16d5, 0x650a,
>  					      USB_CLASS_COMM,
> diff --git a/drivers/usb/serial/option.c b/drivers/usb/serial/option.c
> index 558adfc..569caf6 100644
> --- a/drivers/usb/serial/option.c
> +++ b/drivers/usb/serial/option.c
> @@ -196,6 +196,7 @@ static void option_instat_callback(struct urb *urb);
>  
>  #define DELL_PRODUCT_5800_MINICARD_VZW		0x8195  /* Novatel E362 */
>  #define DELL_PRODUCT_5800_V2_MINICARD_VZW	0x8196  /* Novatel E362 */
> +#define DELL_PRODUCT_5804_MINICARD_ATT		0x819b  /* Novatel E371 */
>  
>  #define KYOCERA_VENDOR_ID			0x0c88
>  #define KYOCERA_PRODUCT_KPC650			0x17da
> @@ -770,6 +771,7 @@ static const struct usb_device_id option_ids[] = {
>  	{ USB_DEVICE(DELL_VENDOR_ID, DELL_PRODUCT_5730_MINICARD_VZW) }, 	/* Dell Wireless 5730 Mobile Broadband EVDO/HSPA Mini-Card */
>  	{ USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, DELL_PRODUCT_5800_MINICARD_VZW, 0xff, 0xff, 0xff) },
>  	{ USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, DELL_PRODUCT_5800_V2_MINICARD_VZW, 0xff, 0xff, 0xff) },
> +	{ USB_DEVICE_AND_INTERFACE_INFO(DELL_VENDOR_ID, DELL_PRODUCT_5804_MINICARD_ATT, 0xff, 0xff, 0xff) },
>  	{ USB_DEVICE(ANYDATA_VENDOR_ID, ANYDATA_PRODUCT_ADU_E100A) },	/* ADU-E100, ADU-310 */
>  	{ USB_DEVICE(ANYDATA_VENDOR_ID, ANYDATA_PRODUCT_ADU_500A) },
>  	{ USB_DEVICE(ANYDATA_VENDOR_ID, ANYDATA_PRODUCT_ADU_620UW) },
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
