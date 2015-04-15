From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH net-next 2/6] net: hip04: use the big endian for tx and rx desc
Date: Wed, 15 Apr 2015 16:13:37 +0200
Message-ID: <6631765.x1c1LvG6uN@wuerfel>
References: <1429101008-9464-1-git-send-email-dingtianhong@huawei.com> <1429101008-9464-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org
To: Ding Tianhong <dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1429101008-9464-3-git-send-email-dingtianhong-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday 15 April 2015 20:30:04 Ding Tianhong wrote:
> The hip04 ethernet use the big endian for tx and rx, so set desc to
> big endian and remove the unused next_addr.

I don't understand:

> diff --git a/drivers/net/ethernet/hisilicon/hip04_eth.c b/drivers/net/ethernet/hisilicon/hip04_eth.c
> index b0a7f03..6473462 100644
> --- a/drivers/net/ethernet/hisilicon/hip04_eth.c
> +++ b/drivers/net/ethernet/hisilicon/hip04_eth.c
> @@ -132,19 +132,18 @@
>  #define HIP04_MIN_TX_COALESCE_FRAMES   1
>  
>  struct tx_desc {
> -       u32 send_addr;
> -       u32 send_size;
> -       u32 next_addr;
> -       u32 cfg;
> -       u32 wb_addr;
> +       __be32 send_addr;
> +       __be32 send_size;
> +       __be32 cfg;
> +       __be32 wb_addr;
>  } __aligned(64);

I would think this is a hardware structure, does this not break
access to the cfg and wb_addr fields if you remove next_addr?

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
