From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 5/9] drivers/net/wireless: correct error-handling code
Date: Tue, 28 Jul 2009 10:30:44 -0700 (PDT)
Message-ID: <20090728.103044.179053537.davem@davemloft.net>
References: <Pine.LNX.4.64.0907281753540.28189@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: julia-dAYI7NvHqcQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.64.0907281753540.28189-QfmoRoYWmW9knbxzx/v8hQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
Date: Tue, 28 Jul 2009 17:54:24 +0200 (CEST)

Wireless patches need to be CC:'d to linux-wireless so that
John Linville can notice and pick them up.  Added...

> From: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> 
> iwm_wdev_alloc returns an ERR_PTR value in an error case instead of NULL.
> 
> A simplified version of the semantic match that finds this problem is as
> follows: (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @match exists@
> expression x, E;
> statement S1, S2;
> @@
> 
> x = iwm_wdev_alloc(...)
> ... when != x = E
> (
> *  if (x == NULL || ...) S1 else S2
> |
> *  if (x == NULL && ...) S1 else S2
> )
> // </smpl>
> 
> Signed-off-by: Julia Lawall <julia-dAYI7NvHqcQ@public.gmane.org>
> 
> ---
>  drivers/net/wireless/iwmc3200wifi/netdev.c     |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwmc3200wifi/netdev.c b/drivers/net/wireless/iwmc3200wifi/netdev.c
> index bb71f8a..e1c6693 100644
> --- a/drivers/net/wireless/iwmc3200wifi/netdev.c
> +++ b/drivers/net/wireless/iwmc3200wifi/netdev.c
> @@ -99,7 +99,7 @@ void *iwm_if_alloc(int sizeof_bus, struct device *dev,
>  	int ret = 0;
>  
>  	wdev = iwm_wdev_alloc(sizeof_bus, dev);
> -	if (!wdev) {
> +	if (IS_ERR(wdev)) {
>  		dev_err(dev, "no memory for wireless device instance\n");
>  		return ERR_PTR(-ENOMEM);
>  	}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
