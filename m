From: David Ahern <dsahern@gmail.com>
Subject: Re: [patch net-next] mlxsw: spectrum_router: Fix build when IPv6
 isn't enabled
Date: Mon, 24 Jul 2017 18:35:36 -0600
Message-ID: <6038dc49-5cd9-6169-8193-b473024c168a@gmail.com>
References: <20170724075600.2798-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36036 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752990AbdGYAfk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 20:35:40 -0400
Received: by mail-pf0-f171.google.com with SMTP id z129so13242840pfb.3
        for <netdev@vger.kernel.org>; Mon, 24 Jul 2017 17:35:39 -0700 (PDT)
In-Reply-To: <20170724075600.2798-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/24/17 1:56 AM, Jiri Pirko wrote:
> @@ -949,9 +950,13 @@ mlxsw_sp_router_neighs_update_interval_init(struct mlxsw_sp *mlxsw_sp)
>  {
>  	unsigned long interval;
>  
> +#if IS_ENABLED(CONFIG_IPV6)
>  	interval = min_t(unsigned long,
>  			 NEIGH_VAR(&arp_tbl.parms, DELAY_PROBE_TIME),
>  			 NEIGH_VAR(&nd_tbl.parms, DELAY_PROBE_TIME));
> +#else
> +	interval = NEIGH_VAR(&arp_tbl.parms, DELAY_PROBE_TIME);
> +#endif
>  	mlxsw_sp->router->neighs_update.interval = jiffies_to_msecs(interval);
>  }
>  

arp and ndisc should have accessors for those rather than exporting the
tables to drivers.
