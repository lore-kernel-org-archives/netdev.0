From: Jingoo Han <jg1.han-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] net: wireless: iwlegacy: fix build error for il_pm_ops
Date: Fri, 31 May 2013 15:22:24 +0900
Message-ID: <000101ce5dc7$374e8190$a5eb84b0$@samsung.com>
References: <1369980332-1344-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, 'Hanjun Guo' <guohanjun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	'Jiang Liu' <liuj97-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	'Stanislaw Gruszka' <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"'John W. Linville'" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jingoo Han <jg1.han-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
To: 'Yijing Wang' <wangyijing-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	"'David S. Miller'" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <1369980332-1344-1-git-send-email-wangyijing-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Content-language: ko
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Friday, May 31, 2013 3:06 PM, Yijing Wang wrote:
> 
> Fix build error for il_pm_ops if CONFIG_PM is set
> but CONFIG_PM_SLEEP is not set.
> 
> ERROR: "il_pm_ops" [drivers/net/wireless/iwlegacy/iwl4965.ko] undefined!
> ERROR: "il_pm_ops" [drivers/net/wireless/iwlegacy/iwl3945.ko] undefined!
> make[1]: *** [__modpost] Error 1
> make: *** [modules] Error 2
> 
> Signed-off-by: Yijing Wang <wangyijing-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Cc: Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Cc: Jingoo Han <jg1.han-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>

It looks good.
As you did, 'struct dev_pm_ops il_pm_ops' should be protected
by CONFIG_PM_SLEEP.

Acked-by: Jingoo Han <jg1.han-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>

Best regards,
Jingoo Han

> ---
>  drivers/net/wireless/iwlegacy/common.h |    6 +++---
>  1 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/wireless/iwlegacy/common.h b/drivers/net/wireless/iwlegacy/common.h
> index f8246f2..4caaf52 100644
> --- a/drivers/net/wireless/iwlegacy/common.h
> +++ b/drivers/net/wireless/iwlegacy/common.h
> @@ -1832,16 +1832,16 @@ u32 il_usecs_to_beacons(struct il_priv *il, u32 usec, u32 beacon_interval);
>  __le32 il_add_beacon_time(struct il_priv *il, u32 base, u32 addon,
>  			  u32 beacon_interval);
> 
> -#ifdef CONFIG_PM
> +#ifdef CONFIG_PM_SLEEP
>  extern const struct dev_pm_ops il_pm_ops;
> 
>  #define IL_LEGACY_PM_OPS	(&il_pm_ops)
> 
> -#else /* !CONFIG_PM */
> +#else /* !CONFIG_PM_SLEEP */
> 
>  #define IL_LEGACY_PM_OPS	NULL
> 
> -#endif /* !CONFIG_PM */
> +#endif /* !CONFIG_PM_SLEEP */
> 
>  /*****************************************************
>  *  Error Handling Debugging
> --
> 1.7.1


--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
