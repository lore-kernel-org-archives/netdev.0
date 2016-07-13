From: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch] net/mlx5: missing error code in
 esw_create_offloads_fdb_table()
Date: Wed, 13 Jul 2016 14:19:06 +0300
Message-ID: <83d5a5bb-dbf5-6c8f-39ea-320d55026a9d@mellanox.com>
References: <20160713100825.GD29468@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160713100825.GD29468@mwanda>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 13/07/2016 13:08, Dan Carpenter wrote:
> We accidentally return success when we had intended to return an error
> code.
>
> Fixes: 69697b6e2086 ('net/mlx5: E-Switch, Add support for the sriov offloads mode')
> Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
>
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> index 1842dfb..7d982cf 100644
> --- a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> @@ -183,6 +183,7 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
>
>  	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_FDB);
>  	if (!root_ns) {
> +		err = -EINVAL;
>  		esw_warn(dev, "Failed to get FDB flow namespace\n");
>  		goto ns_err;
>  	}
>

Hi,

Thanks for the patch.
I'm not sure EINVAL is the right error here though.
Maybe -ENOTSUPP is a bit more appropriate here.

Regards,
Matan
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
