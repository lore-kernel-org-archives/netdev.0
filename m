From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [patch -next] mlx5_core: warn if no space left in alloc_4k()
Date: Sun, 3 Nov 2013 09:03:27 +0200
Message-ID: <20131103070326.GA3051@mtldesk30>
References: <20131101102044.GB29795@longonot.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20131101102044.GB29795-dZEljifmRObu9KfB+GxooP8+0UxHXcjY@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 01, 2013 at 01:20:44PM +0300, Dan Carpenter wrote:
> The warning was unreachable.  In the original code, it would print the
> line number and the function but I have added an error message.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
> I haven't tested this, hopefully the warning is not annoying.
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> index ba816c2..cb86265 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c
> @@ -193,8 +193,8 @@ static int alloc_4k(struct mlx5_core_dev *dev, u64 *addr)
>  	unsigned n;
>  
>  	if (list_empty(&dev->priv.free_list)) {
> +		mlx5_core_warn(dev, "no available space\n");
>  		return -ENOMEM;
> -		mlx5_core_warn(dev, "\n");
>  	}

What we really need to do here is silently return -ENOMEM. The list
can be found empty on a regular basis so we don't want to flood dmesg
with annoying messages. The statement was probably left there from a
previous debug cycle.

>  
>  	fp = list_entry(dev->priv.free_list.next, struct fw_page, list);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
