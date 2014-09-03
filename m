From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] mlx4_en: Convert the normal skb free path to
 dev_consume_skb_any()
Date: Wed, 03 Sep 2014 10:53:01 -0700
Message-ID: <1409766781.26422.51.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140903161800.301F629002CD@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, amirv@mellanox.com, davem@davemloft.net
To: Rick Jones <raj@tardy.usa.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:50168 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbaICRxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 13:53:08 -0400
Received: by mail-pd0-f177.google.com with SMTP id r10so11471219pdi.22
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 10:53:03 -0700 (PDT)
In-Reply-To: <20140903161800.301F629002CD@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-03 at 09:18 -0700, Rick Jones wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> It would appear the mlx4_en driver was still making a call to
> dev_kfree_skb_any() where dev_consume_skb_any() would be more
> appropriate.  This should make dropped packet profiling/tracking
> easier/better over a NIC driven by mlx4_en.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> ---
> 
> Compile tested only
> 
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index dae3da6..bc8f51c 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -319,7 +319,7 @@ static u32 mlx4_en_free_tx_desc(struct mlx4_en_priv *priv,
>  			}
>  		}
>  	}
> -	dev_kfree_skb_any(skb);
> +	dev_consume_skb_any(skb);
>  	return tx_info->nr_txbb;
>  }
>  

I use a similar patch here, I confirm this works.

Acked-by: Eric Dumazet <edumazet@google.com>
