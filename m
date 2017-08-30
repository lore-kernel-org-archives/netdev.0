From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 7/8] mlxsw: spectrum_router: Add support for
 setting counters on IPv6 neighbors
Date: Wed, 30 Aug 2017 11:43:49 -0600
Message-ID: <f99c5f8c-b38c-5f0f-a7dc-64cabd0d117f@gmail.com>
References: <20170830120306.6128-1-jiri@resnulli.us>
 <20170830120306.6128-8-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33386 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751439AbdH3Rnv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 13:43:51 -0400
Received: by mail-pg0-f66.google.com with SMTP id m15so5562974pgc.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 10:43:51 -0700 (PDT)
In-Reply-To: <20170830120306.6128-8-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/30/17 6:03 AM, Jiri Pirko wrote:
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> index db57c0c..0cf6810 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
> @@ -1008,21 +1008,33 @@ mlxsw_sp_neigh_entry_remove(struct mlxsw_sp *mlxsw_sp,
>  }
>  
>  static bool
> -mlxsw_sp_neigh4_counter_should_alloc(struct mlxsw_sp *mlxsw_sp)
> +mlxsw_sp_neigh_counter_should_alloc(struct mlxsw_sp *mlxsw_sp,
> +				    struct mlxsw_sp_neigh_entry *neigh_entry)
>  {
>  	struct devlink *devlink;
> +	const char *table_name;
> +
> +	switch (mlxsw_sp_neigh_entry_type(neigh_entry)) {
> +	case AF_INET:
> +		table_name = MLXSW_SP_DPIPE_TABLE_NAME_HOST4;
> +		break;
> +	case AF_INET6:
> +		table_name = MLXSW_SP_DPIPE_TABLE_NAME_HOST6;
> +		break;
> +	default:
> +		WARN_ON(1);

Another unnecessary WARN_ON

> +		return false;
> +	}
>  
>  	devlink = priv_to_devlink(mlxsw_sp->core);
> -	return devlink_dpipe_table_counter_enabled(devlink,
> -						   MLXSW_SP_DPIPE_TABLE_NAME_HOST4);
> +	return devlink_dpipe_table_counter_enabled(devlink, table_name);
>  }
>  
