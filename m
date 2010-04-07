From: "Maulik" <x0082077@ti.com>
Subject: RE: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
Date: Wed, 7 Apr 2010 11:16:12 +0530
Message-ID: <002801cad615$a352f2a0$808918ac@apr.dhcp.ti.com>
References: <1270599787.8900.8.camel@Linuxdev4-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <rfiler@sierrawireless.com>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>
To: "'Elina Pasheva'" <epasheva@sierrawireless.com>,
	<dbrownell@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:50216 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752549Ab0DGFq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Apr 2010 01:46:26 -0400
In-Reply-To: <1270599787.8900.8.camel@Linuxdev4-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: linux-usb-owner@vger.kernel.org [mailto:linux-usb-
> owner@vger.kernel.org] On Behalf Of Elina Pasheva
> Sent: Wednesday, April 07, 2010 5:53 AM
> To: dbrownell@users.sourceforge.net
> Cc: epasheva@sierrawireless.com; rfiler@sierrawireless.com;
> netdev@vger.kernel.org; linux-usb@vger.kernel.org
> Subject: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
> 
> Subject: [PATCH 1/1] NET: usb: Adding URB_ZERO_PACKET flag to usbnet.c
> From: Elina Pasheva <epasheva@sierrawireless.com>
> This patch adds setting of the urb transfer flag URB_ZERO_PACKET  before
> submitting an urb for drivers that have requested it (by advertising flag
> FLAG_SEND_ZLP).
> The modification is in usbnet.c function usbnet_start_xmit().
> This patch only adds the zero length flag.
> A subsequent patch will address the buggy code we found when devices do
> not
> advertise FLAG_SEND_ZLP in which case there is a possibility of
> transferring
> packets with non-deterministic length.
> 
> This patch has been tested on kernel-2.6.34-rc3.
> This patch has been checked against net-2.6 tree.
> Signed-off-by: Elina Pasheva <epasheva@sierrawireless.com>
> Signed-off-by: Rory Filer <rfiler@sierrawireless.com>
> ---
> 
>  drivers/net/usb/usbnet.c |   15 +++++++++------
>  1 file changed, 9 insertions(+), 6 deletions(-)
> 
> --- a/drivers/net/usb/usbnet.c	2010-04-06 10:52:54.000000000 -0700
> +++ b/drivers/net/usb/usbnet.c	2010-04-06 16:54:44.000000000 -0700
> @@ -1068,12 +1068,15 @@ netdev_tx_t usbnet_start_xmit (struct sk
>  	 * NOTE:  strictly conforming cdc-ether devices should expect
>  	 * the ZLP here, but ignore the one-byte packet.
>  	 */
> -	if (!(info->flags & FLAG_SEND_ZLP) && (length % dev->maxpacket) ==
> 0) {
> -		urb->transfer_buffer_length++;
> -		if (skb_tailroom(skb)) {
> -			skb->data[skb->len] = 0;
> -			__skb_put(skb, 1);
> -		}
> +	if (length % dev->maxpacket == 0) {
> +		if (!(info->flags & FLAG_SEND_ZLP)) {
> +			urb->transfer_buffer_length++;
> +			if (skb_tailroom(skb)) {
> +				skb->data[skb->len] = 0;
> +				__skb_put(skb, 1);
> +			}
> +		} else
> +			urb->transfer_flags |= URB_ZERO_PACKET;

You should place braces for the else case as well. See
Documentation/CodingStyle.

It states to use braces in both the branches since the if() case 
contains multiple statements. 

Maulik

