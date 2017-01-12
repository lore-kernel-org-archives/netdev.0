From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH] [net] net/mlx5e: fix another -Wmaybe-uninitialized
 warning
Date: Thu, 12 Jan 2017 10:30:24 +0200
Message-ID: <5cc9060f-6802-8634-f144-4637e9576ef1@mellanox.com>
References: <20170111211451.2705705-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        "David S . Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0040.outbound.protection.outlook.com ([104.47.2.40]:9942
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750734AbdALIac (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Jan 2017 03:30:32 -0500
In-Reply-To: <20170111211451.2705705-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/11/2017 11:14 PM, Arnd Bergmann wrote:
> @@ -666,14 +666,15 @@ static int mlx5e_route_lookup_ipv4(struct mlx5e_priv *priv,
>   	struct rtable *rt;
>   	struct neighbour *n = NULL;
>   	int ttl;
> +	int ret;
> +
> +	if (!IS_ENABLED(CONFIG_INET))
> +		return -EOPNOTSUPP;
>   
> -#if IS_ENABLED(CONFIG_INET)
>   	rt = ip_route_output_key(dev_net(mirred_dev), fl4);
> -	if (IS_ERR(rt))
> -		return PTR_ERR(rt);
> -#else
> -	return -EOPNOTSUPP;
> -#endif
> +	ret = PTR_ERR_OR_ZERO(rt);
> +	if (ret)
> +		return ret;

but this means that if we got NULL from ip_route_output_key, we will 
return success (0) here which is wrong.
