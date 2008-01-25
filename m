From: David Brownell <david-b-yBeKhBN/0LDR7s880joybQ@public.gmane.org>
Subject: Re: [PATCH 13/14] [rndis_host] blacklist known wireless RNDIS devices
Date: Thu, 24 Jan 2008 17:13:17 -0800
Message-ID: <200801241713.18238.david-b@pacbell.net>
References: <20080120001455.25718.75424.stgit@fate.lan>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bjd-a1rhEgazXTw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080120001455.25718.75424.stgit-q/85JClnwdg@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 19 January 2008, Jussi Kivilinna wrote:
> Blacklist known wireless RNDIS devices that will be handled by
> rndis_wext module.

This seems destined to become a headache.  Wouldn't it be better
to let the probe progress far enough to detect that it's actually
a WLAN device, and then back out so the next driver can try?

- Dave


> Signed-off-by: Jussi Kivilinna <jussi.kivilinna-E01nCVcF24I@public.gmane.org>
> ---
> 
>  drivers/net/usb/rndis_host.c |  104 ++++++++++++++++++++++++++++++++++++++++++
>  1 files changed, 104 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
> index 1ffbbb3..cd1f953 100644
> --- a/drivers/net/usb/rndis_host.c
> +++ b/drivers/net/usb/rndis_host.c
> @@ -530,6 +530,110 @@ static const struct driver_info	rndis_info = {
>  /*-------------------------------------------------------------------------*/
>  
>  static const struct usb_device_id	products [] = {
> +/*
> + * BLACKLIST !!
> + *
> + * Blacklist RNDIS devices that are handled in separate RNDIS modules.
> + */
> +
> +#define	RNDIS_MASTER_INTERFACE \
> +	.bInterfaceClass	= USB_CLASS_COMM, \
> +	.bInterfaceSubClass	= 2 /* ACM */, \
> +	.bInterfaceProtocol	= 0x0ff
> +
> +/* Wireless RNDIS devices, rndis_wext module */
> +{
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x0411,
> +	.idProduct		= 0x00bc,	/* Buffalo WLI-U2-KG125S */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x0baf,
> +	.idProduct		= 0x011b,	/* U.S. Robotics USR5421 */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x050d,
> +	.idProduct		= 0x011b,	/* Belkin F5D7051 */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x1799,	/* Belkin has two vendor ids */
> +	.idProduct		= 0x011b,	/* Belkin F5D7051 */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x13b1,
> +	.idProduct		= 0x0014,	/* Linksys WUSB54GSv2 */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x13b1,
> +	.idProduct		= 0x0026,	/* Linksys WUSB54GSC */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x0b05,
> +	.idProduct		= 0x1717,	/* Asus WL169gE */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x0a5c,
> +	.idProduct		= 0xd11b,	/* Eminent EM4045 */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x1690,
> +	.idProduct		= 0x0715,	/* BT Voyager 1055 */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x13b1,
> +	.idProduct		= 0x000e,	/* Linksys WUSB54GSv1 */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x0baf,
> +	.idProduct		= 0x0111,	/* U.S. Robotics USR5420 */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +}, {
> +	.match_flags	=   USB_DEVICE_ID_MATCH_INT_INFO
> +			  | USB_DEVICE_ID_MATCH_DEVICE,
> +	.idVendor		= 0x0411,
> +	.idProduct		= 0x004b,	/* BUFFALO WLI-USB-G54 */
> +	RNDIS_MASTER_INTERFACE,
> +	.driver_info		= 0,
> +},
> +
> +/*
> + * WHITELIST!!!
> + *
> + * All other RNDIS devices that do not need special OID handling in order
> + * to work.
> + */
>  {
>  	/* RNDIS is MSFT's un-official variant of CDC ACM */
>  	USB_INTERFACE_INFO(USB_CLASS_COMM, 2 /* ACM */, 0x0ff),
> 
