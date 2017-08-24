From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next 12/12] mlxsw: spectrum_dpipe: Add support for
 controlling neighbor counters
Date: Thu, 24 Aug 2017 12:28:09 -0700
Message-ID: <611f74bf-946d-1429-f002-bfcaa0261990@gmail.com>
References: <20170824064010.1646-1-jiri@resnulli.us>
 <20170824064010.1646-13-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34097 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdHXT2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 15:28:11 -0400
Received: by mail-pg0-f66.google.com with SMTP id 63so607576pgc.1
        for <netdev@vger.kernel.org>; Thu, 24 Aug 2017 12:28:11 -0700 (PDT)
In-Reply-To: <20170824064010.1646-13-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/23/17 11:40 PM, Jiri Pirko wrote:
> diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
> index 94d954b..3c8599f 100644
> --- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
> +++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
> @@ -599,6 +599,38 @@ mlxsw_sp_dpipe_table_host4_entries_dump(void *priv, bool counters_enabled,
>  						      dump_ctx, AF_INET);
>  }
>  
> +static void
> +mlxsw_sp_dpipe_table_host_counters_update(struct mlxsw_sp *mlxsw_sp,
> +					  bool enable, int type)
> +{
> +	int i;
> +
> +	rtnl_lock();

same question here. Why is rtnl lock needed?

> +	for (i = 0; i < MLXSW_CORE_RES_GET(mlxsw_sp->core, MAX_RIFS); i++) {
> +		struct mlxsw_sp_rif *rif = mlxsw_sp_rif_by_index(mlxsw_sp, i);
> +		struct mlxsw_sp_neigh_entry *neigh_entry;
> +
> +		if (!rif)
> +			continue;
> +		mlxsw_sp_rif_neigh_for_each(neigh_entry, rif) {
> +			if (mlxsw_sp_neigh_entry_type(neigh_entry) != type)
> +				continue;
> +			mlxsw_sp_neigh_entry_counter_update(mlxsw_sp,
> +							    neigh_entry,
> +							    enable);
> +		}
> +	}
> +	rtnl_unlock();
