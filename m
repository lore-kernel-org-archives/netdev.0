From: Greg KH <greg@kroah.com>
Subject: Re: Subject: re-submit4 [ANNOUNCEMENT] NET: usb: sierra_net.c
 driver
Date: Thu, 22 Apr 2010 12:44:35 -0700
Message-ID: <20100422194435.GA14544@kroah.com>
References: <1271963973.10035.6.camel@Linuxdev4-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dbrownell@users.sourceforge.net, davem@davemloft.net,
	rfiler@sierrawireless.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Elina Pasheva <epasheva@sierrawireless.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:56953 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757238Ab0DVTqF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 15:46:05 -0400
Content-Disposition: inline
In-Reply-To: <1271963973.10035.6.camel@Linuxdev4-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 22, 2010 at 12:19:33PM -0700, Elina Pasheva wrote:
> +static void sierra_net_send_cmd(struct usbnet *dev,
> +		u8 *cmd, int cmdlen, const char * cmd_name)
> +{
> +	struct sierra_net_data *priv = sierra_net_get_private(dev);
> +	int  status;
> +
> +	status = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
> +			USB_CDC_SEND_ENCAPSULATED_COMMAND,
> +			USB_DIR_OUT|USB_TYPE_CLASS|USB_RECIP_INTERFACE,	0,
> +			priv->ifnum, cmd, cmdlen, 0);

No timeout?

> +		ifnum = priv->ifnum;
> +		len = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> +				USB_CDC_GET_ENCAPSULATED_RESPONSE,
> +				USB_DIR_IN|USB_TYPE_CLASS|USB_RECIP_INTERFACE,
> +				0, ifnum, buf, SIERRA_NET_USBCTL_BUF_LEN, 0);

No timeout?

> +		if (unlikely(len < 0)) {
> +			netdev_err(dev->net,
> +				"usb_control_msg failed, status %d\n", len);

You don't need "unlikely", this is an extreemly slow path here.
Also, what happens for a "short read"?  You don't handle that properly.

thanks,

greg k-h
