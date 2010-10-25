From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH] drivers: rtl818x: request DMA-able memory
Date: Mon, 25 Oct 2010 09:35:56 -0400
Message-ID: <20101025133555.GB2414@tuxdriver.com>
References: <1287952327-9924-1-git-send-email-sez@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herton@mandriva.com.br, htl10@users.sourceforge.net,
	Larry.Finger@lwfinger.net, joe@perches.com, davem@davemloft.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Serafeim Zanikolas <sez@debian.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1287952327-9924-1-git-send-email-sez@debian.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Oct 24, 2010 at 10:32:07PM +0200, Serafeim Zanikolas wrote:
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

Are you sure about this?  Are there USB controllers out there with
the ISA 16MB limitation for DMA?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
