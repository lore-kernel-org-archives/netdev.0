From: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH] netdevice zd1201: Convert directly reference of netdev->priv
 to netdev_priv()
Date: Mon, 03 Nov 2008 10:06:28 +0800
Message-ID: <490E5CA4.4010707@cn.fujitsu.com>
References: <20081031182207.GD4310@tuxdriver.com> <1225478896-28987-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	NETDEV <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1225478896-28987-1-git-send-email-linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

John W. Linville said the following on 2008-11-1 2:48:
> We have some reasons to kill netdev->priv:
> 1. netdev->priv is equal to netdev_priv().
> 2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
>    netdev_priv() is more flexible than netdev->priv.
> But we cann't kill netdev->priv, because so many drivers reference to it
> directly.
> 
> OK, becasue Dave S. Miller said, "every direct netdev->priv usage is a bug",
> and I want to kill netdev->priv later, I decided to convert all the direct
> reference of netdev->priv first.
> 
> (Original patch posted by Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> w/ above
> changelog but using dev->ml_priv.  That doesn't seem appropriate
> to me for this driver, so I've revamped it to use netdev_priv()
> instead. -- JWL)
> 
> Cc: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
> Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> ---
>  drivers/net/wireless/zd1201.c |  115 ++++++++++++++++++++---------------------
>  1 files changed, 56 insertions(+), 59 deletions(-)
> 
snip...
> @@ -1731,6 +1731,7 @@ static int zd1201_probe(struct usb_interface *interface,
>  			const struct usb_device_id *id)
>  {
>  	struct zd1201 *zd;
> +	struct net_device *dev;
>  	struct usb_device *usb;
>  	int err;
>  	short porttype;
> @@ -1738,9 +1739,12 @@ static int zd1201_probe(struct usb_interface *interface,
>  
>  	usb = interface_to_usbdev(interface);
>  
> -	zd = kzalloc(sizeof(struct zd1201), GFP_KERNEL);
> -	if (!zd)
> +	dev = alloc_etherdev(sizeof(*zd));
> +	if (!dev)
>  		return -ENOMEM;
> +	zd = netdev_priv(dev);
> +	zd->dev = dev;
> +

It's ok to me.

Reviewed-by: Wang Chen <wangchen-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
