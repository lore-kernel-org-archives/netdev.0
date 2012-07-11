From: Hadar Hen Zion <hadarh@mellanox.com>
Subject: Re: [patch] net/mlx4: off by one in parse_trans_rule()
Date: Wed, 11 Jul 2012 17:51:50 +0300
Message-ID: <4FFD9306.3000600@mellanox.com>
References: <20120711063336.GC11812@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hadar Hen Zion <hadarh@mellanox.co.il>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>,
	<netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog105.obsmtp.com ([207.126.144.119]:42575 "HELO
	eu1sys200aog105.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755442Ab2GKOyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 10:54:39 -0400
In-Reply-To: <20120711063336.GC11812@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/11/2012 9:33 AM, Dan Carpenter wrote:
> This should be ">=" here instead of ">".  MLX4_NET_TRANS_RULE_NUM is 6.
> We use "spec->id" as an array offset into the __rule_hw_sz[] and
> __sw_id_hw[] arrays which have 6 elements.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
> index bc62f53..5bac0df 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
> @@ -773,7 +773,7 @@ static int parse_trans_rule(struct mlx4_dev *dev, struct mlx4_spec_list *spec,
>   		[MLX4_NET_TRANS_RULE_ID_UDP] =
>   			sizeof(struct mlx4_net_trans_rule_hw_tcp_udp)
>   	};
> -	if (spec->id > MLX4_NET_TRANS_RULE_NUM) {
> +	if (spec->id >= MLX4_NET_TRANS_RULE_NUM) {
>   		mlx4_err(dev, "Invalid network rule id. id = %d\n", spec->id);
>   		return -EINVAL;
>   	}
>

Hi Dan,

This is indeed a bug, thanks for spotting this over,

Please add:
Acked-by: Hadar Hen Zion <hadarh@mellanox.co.il>

Hadar
