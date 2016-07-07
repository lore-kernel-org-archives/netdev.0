From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch -next] mlxsw: spectrum_router: fix a use after free
Date: Thu, 7 Jul 2016 10:39:22 +0200
Message-ID: <20160707083922.GE2009@nanopsycho.orion>
References: <20160707082027.GB16742@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160707082027.GB16742@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, Jul 07, 2016 at 10:20:28AM CEST, dan.carpenter@oracle.com wrote:
>mlxsw_sp_fib_entry_destroy() frees "fib_entry" but we dereference it on
>the next line.
>
>Fixes: 61c503f976b5 ('mlxsw: spectrum_router: Implement fib4 add/del switchdev obj ops')
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
>diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>index e084ea5..adb481a 100644
>--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
>@@ -1652,8 +1652,8 @@ static void mlxsw_sp_router_fib4_add_info_destroy(void const *data)
> 	struct mlxsw_sp_fib_entry *fib_entry = info->fib_entry;
> 	struct mlxsw_sp *mlxsw_sp = info->mlxsw_sp;


To be consistent with the rest of the flows, I would rather do:

	struct mlxsw_sp_vr *vr = fib_entry->vr;

	mlxsw_sp_fib_entry_destroy(fib_entry);
 	mlxsw_sp_vr_put(mlxsw_sp, vr);



I can send the fix or I can leave it up to you. Thanks.
