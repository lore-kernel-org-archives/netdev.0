From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net-next 2/2] net/mlx4_en: Support for configurable RSS
 hash function
Date: Wed, 5 Nov 2014 15:53:12 +0200
Message-ID: <545A2BC8.4030304@mellanox.com>
References: <1415188769-19593-1-git-send-email-amirv@mellanox.com> <1415188769-19593-3-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>, <netdev@vger.kernel.org>,
	"Yevgeny Petrilin" <yevgenyp@mellanox.com>
To: Eyal Perry <eyalpe@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:55916 "EHLO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751198AbaKENxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 08:53:22 -0500
In-Reply-To: <1415188769-19593-3-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 11/5/2014 1:59 PM, Amir Vadai wrote:
> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
> @@ -2585,6 +2585,15 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
>   		dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
>   	}
>   
> +	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_XOR) {
> +		priv->rss_hash_fn_caps |= RSS_HASH_XOR;
> +		priv->rss_hash_fn = RSS_HASH_XOR;
> +	}
> +	if (mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_RSS_TOP) {
> +		priv->rss_hash_fn_caps |= RSS_HASH_TOP;
> +		priv->rss_hash_fn = RSS_HASH_TOP;
> +	}
> +

can we somehow change this code to be more clear and assign 
priv->rss_hash_fn once?

>   	mdev->pndev[port] = dev;
>   
>   	netif_carrier_off(dev);
