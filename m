From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH] drivers: rtl818x: request DMA-able memory
Date: Mon, 25 Oct 2010 08:24:45 -0500
Message-ID: <4CC5851D.1040204@lwfinger.net>
References: <1287952327-9924-1-git-send-email-sez@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: herton@mandriva.com.br, htl10@users.sourceforge.net,
	linville@tuxdriver.com, joe@perches.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Serafeim Zanikolas <sez@debian.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50898 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414Ab0JYNYf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 09:24:35 -0400
In-Reply-To: <1287952327-9924-1-git-send-email-sez@debian.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2010 03:32 PM, Serafeim Zanikolas wrote:
> Despite the indicated intention in comment, the kmalloc() call was not
> explicitly requesting memory from ZONE_DMA.
> 
> Signed-off-by: Serafeim Zanikolas <sez@debian.org>
> ---
>  drivers/net/wireless/rtl818x/rtl8187_dev.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/rtl818x/rtl8187_dev.c b/drivers/net/wireless/rtl818x/rtl8187_dev.c
> index 38fa824..771794d 100644
> --- a/drivers/net/wireless/rtl818x/rtl8187_dev.c
> +++ b/drivers/net/wireless/rtl818x/rtl8187_dev.c
> @@ -1343,7 +1343,8 @@ static int __devinit rtl8187_probe(struct usb_interface *intf,
>  	priv->is_rtl8187b = (id->driver_info == DEVICE_RTL8187B);
>  
>  	/* allocate "DMA aware" buffer for register accesses */
> -	priv->io_dmabuf = kmalloc(sizeof(*priv->io_dmabuf), GFP_KERNEL);
> +	priv->io_dmabuf = kmalloc(sizeof(*priv->io_dmabuf),
> +				  GFP_DMA | GFP_KERNEL);
>  	if (!priv->io_dmabuf) {
>  		err = -ENOMEM;
>  		goto err_free_dev;

ACK.

Larry

