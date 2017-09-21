From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next 07/12] mlxsw: spectrum: Add the multicast
 routing offloading logic
Date: Thu, 21 Sep 2017 17:26:54 +0200
Message-ID: <20170921152654.GF27589@lunn.ch>
References: <20170921064338.1282-1-jiri@resnulli.us>
 <20170921064338.1282-8-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yotamg@mellanox.com,
        idosch@mellanox.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([185.16.172.187]:51405 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751799AbdIUP07 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 21 Sep 2017 11:26:59 -0400
Content-Disposition: inline
In-Reply-To: <20170921064338.1282-8-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static void mlxsw_sp_mr_route_stats_update(struct mlxsw_sp *mlxsw_sp,
> +					   struct mlxsw_sp_mr_route *mr_route)
> +{
> +	struct mlxsw_sp_mr *mr = mlxsw_sp->mr;
> +	u64 packets, bytes;
> +
> +	if (mr_route->route_action == MLXSW_SP_MR_ROUTE_ACTION_TRAP)
> +		return;
> +
> +	mr->mr_ops->route_stats(mlxsw_sp, mr_route->route_priv, &packets,
> +				&bytes);
> +
> +	switch (mr_route->mr_table->proto) {
> +	case MLXSW_SP_L3_PROTO_IPV4:
> +		mr_route->mfc4->mfc_un.res.pkt = packets;
> +		mr_route->mfc4->mfc_un.res.bytes = bytes;

What about wrong_if and lastuse? 

Is an mfc with iif on the host, not the switch, not offloaded?

   Andrew
