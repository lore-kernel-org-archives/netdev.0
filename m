From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCH 4/5] usb: usbnet: Add validation of dev->maxpacket to usbnet
Date: Wed, 15 Feb 2012 20:34:02 +0100
Message-ID: <201202152034.03000.oliver@neukum.org>
References: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com> <1329317261-3406-5-git-send-email-toby.gray@realvnc.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Toby Gray <tg@realvnc.com>, Oliver Neukum <oliver@neukum.name>,
	"Greg Kroah-Hartman" <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	alexey.orishko@gmail.com
To: Toby Gray <toby.gray@realvnc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:54285 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754488Ab2BOTbf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 14:31:35 -0500
In-Reply-To: <1329317261-3406-5-git-send-email-toby.gray@realvnc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Mittwoch, 15. Februar 2012, 15:47:40 schrieb Toby Gray:
> Several parts of usbnet rely on dev->maxpacket not being set to 0 to
> prevent division by zero errors.
> 
> This adds validation of the dev->maxpacket value being non-zero before
> treating the device probe as successful.
> 
> Signed-off-by: Toby Gray <toby.gray@realvnc.com>
> ---
>  drivers/net/usb/usbnet.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 4ccd316..1491c90 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1427,6 +1427,10 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
>  		dev->rx_urb_size = dev->hard_mtu;
>  	if (!dev->maxpacket)
>  		dev->maxpacket = usb_maxpacket(dev->udev, dev->out, 1);
> +	if (!dev->maxpacket) {
> +		status = -ENODEV;
> +		goto out3;

Hm. I am sceptical. If this happens a subdriver is buggy. We should
not hide that. I am afraid I have to reject this patch.

	Regards
		Oliver
