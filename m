From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH 01/12] usbnet: introduce usbnet 3 command helpers
Date: Tue, 09 Oct 2012 10:47:03 +0200
Message-ID: <1765908.3QOFSVW2eC@linux-lqwf.site>
References: <1349160684-6627-1-git-send-email-ming.lei@canonical.com> <1349160684-6627-2-git-send-email-ming.lei@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33230 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752124Ab2JIIsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2012 04:48:46 -0400
In-Reply-To: <1349160684-6627-2-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 02 October 2012 14:51:12 Ming Lei wrote:
> This patch introduces the below 3 usb command helpers:
> 
> 	usbnet_read_cmd / usbnet_write_cmd / usbnet_write_cmd_async
> 
> so that each low level driver doesn't need to implement them
> by itself, and the dma buffer allocation for usb transfer and
> runtime PM things can be handled just in one place.
> 
> Signed-off-by: Ming Lei <ming.lei@canonical.com>
> ---
>  drivers/net/usb/usbnet.c   |  133 ++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/usb/usbnet.h |    6 ++
>  2 files changed, 139 insertions(+)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index fc9f578..3b51554 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -1592,6 +1592,139 @@ int usbnet_resume (struct usb_interface *intf)
>  }
>  EXPORT_SYMBOL_GPL(usbnet_resume);
>  
> +/*-------------------------------------------------------------------------*/
> +int usbnet_read_cmd(struct usbnet *dev, u8 cmd, u8 reqtype,
> +		    u16 value, u16 index, void *data, u16 size)
> +{
> +	void *buf = NULL;
> +	int err = -ENOMEM;
> +
> +	netdev_dbg(dev->net, "usbnet_read_cmd cmd=0x%02x reqtype=%02x"
> +		   " value=0x%04x index=0x%04x size=%d\n",
> +		   cmd, reqtype, value, index, size);
> +
> +	if (data) {
> +		buf = kmalloc(size, GFP_KERNEL);

Using GFP_KERNEL you preclude using those in resume() and error handling.
Please pass a gfp_t parameter.

	Regards
		Oliver
