From: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] mlx4_en: remove unnecessary returned value check
Date: Wed, 12 Jul 2017 11:36:48 +0300
Message-ID: <20170712083647.GB2866@yuvallap>
References: <1499841873-10275-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1499841873-10275-1-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 12, 2017 at 02:44:33AM -0400, Zhu Yanjun wrote:
> The function __mlx4_zone_remove_one_entry always returns zero. So
> it is not necessary to check it.
> 
> Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx4/alloc.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
> index 249a458..bfb185d 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
> @@ -283,7 +283,7 @@ int mlx4_zone_add_one(struct mlx4_zone_allocator *zone_alloc,
>  }
>  
>  /* Should be called under a lock */
> -static int __mlx4_zone_remove_one_entry(struct mlx4_zone_entry *entry)
> +static void __mlx4_zone_remove_one_entry(struct mlx4_zone_entry *entry)
>  {
>  	struct mlx4_zone_allocator *zone_alloc = entry->allocator;
>  
> @@ -315,8 +315,6 @@ static int __mlx4_zone_remove_one_entry(struct mlx4_zone_entry *entry)
>  		}
>  		zone_alloc->mask = mask;
>  	}
> -
> -	return 0;
>  }
>  
>  void mlx4_zone_allocator_destroy(struct mlx4_zone_allocator *zone_alloc)
> @@ -468,7 +466,8 @@ int mlx4_zone_remove_one(struct mlx4_zone_allocator *zones, u32 uid)
>  		goto out;
>  	}
>  
> -	res = __mlx4_zone_remove_one_entry(zone);
> +	__mlx4_zone_remove_one_entry(zone);
> +	res = 0;

Will look better if initialization will move to variable declaration.

Besides this minor thing - lgtm.

Reviewed-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

>  
>  out:
>  	spin_unlock(&zones->lock);
> -- 
> 2.7.4
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
