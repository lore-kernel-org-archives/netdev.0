From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Subject: Re: [PATCH] mlx5: avoid build warnings on 32-bit
Date: Tue, 13 Jan 2015 18:28:03 +0200
Message-ID: <20150113162803.GA7414@mtldesk30>
References: <4105686.Jz5UR0277i@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <4105686.Jz5UR0277i@wuerfel>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 13, 2015 at 05:08:06PM +0100, Arnd Bergmann wrote:

Hi Arnd,
wouldn't it work by casting to uintptr_t instead of unsigned long?

> The mlx5 driver passes a string pointer in through a 'u64' variable,
> which on 32-bit machines causes a build warning:
> 
> drivers/net/ethernet/mellanox/mlx5/core/debugfs.c: In function 'qp_read_field':
> drivers/net/ethernet/mellanox/mlx5/core/debugfs.c:303:11: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
> 
> The code is in fact safe, so we can shut up the warning by adding
> extra type casts.
> 
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
> index 10e1f1a18255..4878025e231c 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/debugfs.c
> @@ -300,11 +300,11 @@ static u64 qp_read_field(struct mlx5_core_dev *dev, struct mlx5_core_qp *qp,
>  		param = qp->pid;
>  		break;
>  	case QP_STATE:
> -		param = (u64)mlx5_qp_state_str(be32_to_cpu(ctx->flags) >> 28);
> +		param = (unsigned long)mlx5_qp_state_str(be32_to_cpu(ctx->flags) >> 28);
>  		*is_str = 1;
>  		break;
>  	case QP_XPORT:
> -		param = (u64)mlx5_qp_type_str((be32_to_cpu(ctx->flags) >> 16) & 0xff);
> +		param = (unsigned long)mlx5_qp_type_str((be32_to_cpu(ctx->flags) >> 16) & 0xff);
>  		*is_str = 1;
>  		break;
>  	case QP_MTU:
> @@ -464,7 +464,7 @@ static ssize_t dbg_read(struct file *filp, char __user *buf, size_t count,
>  
>  
>  	if (is_str)
> -		ret = snprintf(tbuf, sizeof(tbuf), "%s\n", (const char *)field);
> +		ret = snprintf(tbuf, sizeof(tbuf), "%s\n", (const char *)(unsigned long)field);
>  	else
>  		ret = snprintf(tbuf, sizeof(tbuf), "0x%llx\n", field);
>  
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
