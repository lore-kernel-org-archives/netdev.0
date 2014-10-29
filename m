From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [patch] SUNRPC: off by one in BUG_ON()
Date: Wed, 29 Oct 2014 11:38:06 -0400
Message-ID: <20141029153806.GB1133@fieldses.org>
References: <20141029084416.GC8939@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20141029084416.GC8939@mwanda>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 29, 2014 at 11:44:16AM +0300, Dan Carpenter wrote:
> The m->pool_to[] array has "maxpools" number of elements.  It's
> allocated in svc_pool_map_alloc_arrays() which we called earlier in the
> function.  This test should be >= instead of >.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
> This is very old code, but hopefully the off by one doesn't affect
> runtime.

Yeah, doesn't look like a big deal, but thanks, applying for 3.19.--b.

> 
> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> index ca8a795..349c98f 100644
> --- a/net/sunrpc/svc.c
> +++ b/net/sunrpc/svc.c
> @@ -189,7 +189,7 @@ svc_pool_map_init_percpu(struct svc_pool_map *m)
>  		return err;
>  
>  	for_each_online_cpu(cpu) {
> -		BUG_ON(pidx > maxpools);
> +		BUG_ON(pidx >= maxpools);
>  		m->to_pool[cpu] = pidx;
>  		m->pool_to[pidx] = cpu;
>  		pidx++;
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
