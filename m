From: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Subject: Re: [PATCH] zd1211rw: Readd zd_addr_t cast
Date: Sat, 10 Feb 2007 07:02:14 +0100
Message-ID: <200702100702.15264.mb@bu3sch.de>
References: <20070210012718.3B6E87B409F@zog.reactivated.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org,
	rpjday-mn4gwa5WIIQysxA8WJXlww@public.gmane.org
To: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070210012718.3B6E87B409F-k/4jFdqg8LLlyo9zxV8I99HuzzzSOjJt@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Saturday 10 February 2007 02:27, Daniel Drake wrote:
> Robert P.J. Day's recent commit ("getting rid of all casts of k[cmz]alloc()
> calls") introduced a sparse warning for zd1211rw, related to our type-checking
> of addresses.
> 
> 	zd_chip.c:116:15: warning: implicit cast to nocast type
> 
> This patch readds the type cast, it is correct.
> 
> Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
> 
> Index: linux/drivers/net/wireless/zd1211rw/zd_chip.c
> ===================================================================
> --- linux.orig/drivers/net/wireless/zd1211rw/zd_chip.c
> +++ linux/drivers/net/wireless/zd1211rw/zd_chip.c
> @@ -113,7 +113,7 @@ int zd_ioread32v_locked(struct zd_chip *
>  
>  	/* Allocate a single memory block for values and addresses. */
>  	count16 = 2*count;
> -	a16 = kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
> +	a16 = (zd_addr_t *) kmalloc(count16 * (sizeof(zd_addr_t) + sizeof(u16)),
>  		                   GFP_NOFS);

Unrelated, but I am wondering since quite some time why you pass GFP_NOFS here.
Any special reason? I think in general there is no good reason for code outside
of the VFS to use this flag.
IMHO you should pass either GFP_ATOMIC or GFP_KERNEL.
-
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
