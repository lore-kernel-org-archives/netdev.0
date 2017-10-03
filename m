From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [PATCH 2/2 net-next] mlxsw: spectrum: Add missing error code on
 allocation failure
Date: Tue, 3 Oct 2017 13:56:46 +0300
Message-ID: <3156691a-78a8-ffd6-d486-57502963b3e5@mellanox.com>
References: <20171003105340.llwk5oajgrohbksu@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Jiri Pirko <jiri@mellanox.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20171003105340.llwk5oajgrohbksu@mwanda>
Content-Language: en-US
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/03/2017 01:53 PM, Dan Carpenter wrote:
> We accidentally return success if the kmalloc_array() call fails.
>
> Fixes: 0e14c7777acb ("mlxsw: spectrum: Add the multicast routing hardware logic")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Yotam Gigi <yotamg@mellanox.com>

>
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
> index 5e4ccbf17e3d..839eadf0765b 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_mr_tcam.c
> @@ -763,8 +763,10 @@ mlxsw_sp_mr_tcam_region_init(struct mlxsw_sp *mlxsw_sp,
>  
>  	parman_prios = kmalloc_array(MLXSW_SP_MR_ROUTE_PRIO_MAX + 1,
>  				     sizeof(*parman_prios), GFP_KERNEL);
> -	if (!parman_prios)
> +	if (!parman_prios) {
> +		err = -ENOMEM;
>  		goto err_parman_prios_alloc;
> +	}
>  	mr_tcam_region->parman_prios = parman_prios;
>  
>  	for (i = 0; i < MLXSW_SP_MR_ROUTE_PRIO_MAX + 1; i++)

