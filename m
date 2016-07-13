From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [patch v2] net/mlx5: missing error code in
 esw_create_offloads_fdb_table()
Date: Wed, 13 Jul 2016 11:54:54 -0600
Message-ID: <20160713175454.GF19657@obsidianresearch.com>
References: <83d5a5bb-dbf5-6c8f-39ea-320d55026a9d@mellanox.com>
 <20160713100825.GD29468@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>, netdev@vger.kernel.org,
	linux-rdma@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:59949 "EHLO quartz.orcorp.ca"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752183AbcGMRzD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 13:55:03 -0400
Content-Disposition: inline
In-Reply-To: <20160713100825.GD29468@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 13, 2016 at 02:48:44PM +0300, Dan Carpenter wrote:
> We accidentally return success when we had intended to return an error
> code.
> 
> Fixes: 69697b6e2086 ('net/mlx5: E-Switch, Add support for the sriov offloads mode')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> v2: return -ENOTSUPP instead --EINVAL
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> index 1842dfb..7d982cf 100644
> +++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> @@ -183,6 +183,7 @@ static int esw_create_offloads_fdb_table(struct mlx5_eswitch *esw, int nvports)
>  
>  	root_ns = mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_FDB);
>  	if (!root_ns) {
> +		err = -ENOTSUPP;

Did you mean ENOTSUP?

I thought ENOTSUPP was not to be used outside NFS, and isn't properly
exported to userspace..

$ find /usr/include -name "*errno*" | xargs grep 524

Jason
