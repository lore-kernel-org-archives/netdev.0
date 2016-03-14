From: Leon Romanovsky <leon-2ukJVAZIZ/Y@public.gmane.org>
Subject: Re: [PATCH 1/5] mlx4: add missing braces in verify_qp_parameters
Date: Mon, 14 Mar 2016 19:57:14 +0200
Message-ID: <20160314175714.GA13848@leon.nu>
References: <1457965120-3155420-1-git-send-email-arnd@arndb.de>
 <1457965120-3155420-2-git-send-email-arnd@arndb.de>
Reply-To: leon-2ukJVAZIZ/Y@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1457965120-3155420-2-git-send-email-arnd-r2nGTMty4D4@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 14, 2016 at 03:18:34PM +0100, Arnd Bergmann wrote:
> The implementation of QP paravirtualization back in linux-3.7 included
> some code that looks very dubious, and gcc-6 has grown smart enough
> to warn about it:
> 
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function 'verify_qp_parameters':
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:3154:5: error: statement is indented as if it were guarded by... [-Werror=misleading-indentation]
>      if (optpar & MLX4_QP_OPTPAR_ALT_ADDR_PATH) {
>      ^~
> drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:3144:4: note: ...this 'if' clause, but it is not
>     if (slave != mlx4_master_func_num(dev))
> 
> From looking at the context, I'm reasonably sure that the indentation
> is correct but that it should have contained curly braces from the
> start, as the update_gid() function in the same patch correctly does.
> 
> Signed-off-by: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> Fixes: 54679e148287 ("mlx4: Implement QP paravirtualization and maintain phys_pkey_cache for smp_snoop")

Thanks, looks good.
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

> ---
>  drivers/net/ethernet/mellanox/mlx4/resource_tracker.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> index 25ce1b030a00..cd9b2b28df88 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
> @@ -3141,7 +3141,7 @@ static int verify_qp_parameters(struct mlx4_dev *dev,
>  		case QP_TRANS_RTS2RTS:
>  		case QP_TRANS_SQD2SQD:
>  		case QP_TRANS_SQD2RTS:
> -			if (slave != mlx4_master_func_num(dev))
> +			if (slave != mlx4_master_func_num(dev)) {
>  				if (optpar & MLX4_QP_OPTPAR_PRIMARY_ADDR_PATH) {
>  					port = (qp_ctx->pri_path.sched_queue >> 6 & 1) + 1;
>  					if (dev->caps.port_mask[port] != MLX4_PORT_TYPE_IB)
> @@ -3160,6 +3160,7 @@ static int verify_qp_parameters(struct mlx4_dev *dev,
>  					if (qp_ctx->alt_path.mgid_index >= num_gids)
>  						return -EINVAL;
>  				}
> +			}
>  			break;
>  		default:
>  			break;
> -- 
> 2.7.0
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
