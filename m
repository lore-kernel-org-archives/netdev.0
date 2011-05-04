From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] mlx4_en: Setting RSS hash result to skb->rxhash field
Date: Wed, 04 May 2011 15:44:20 +0100
Message-ID: <1304520260.3203.34.camel@localhost>
References: <4DC156AF.4050807@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:48563 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754207Ab1EDOoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 10:44:24 -0400
In-Reply-To: <4DC156AF.4050807@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-05-04 at 16:37 +0300, Yevgeny Petrilin wrote:
> Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
> ---
>  drivers/net/mlx4/en_rx.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/mlx4/en_rx.c b/drivers/net/mlx4/en_rx.c
> index 62dd21b..bb4d66a 100644
> --- a/drivers/net/mlx4/en_rx.c
> +++ b/drivers/net/mlx4/en_rx.c
> @@ -610,6 +610,8 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  					gro_skb->data_len = length;
>  					gro_skb->truesize += length;
>  					gro_skb->ip_summed = CHECKSUM_UNNECESSARY;
> +					gro_skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid) << 24;
> +					skb_record_rx_queue(gro_skb, cq->ring);

An 8-bit hash is almost useless.  It's entirely useless if you then
shift it into the top bits of rxhash.

Ben.

>  					if (priv->vlgrp && (cqe->vlan_my_qpn &
>  							    cpu_to_be32(MLX4_CQE_VLAN_PRESENT_MASK)))
> @@ -643,6 +645,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>  			goto next;
>  		}
>  
> +		skb->rxhash = be32_to_cpu(cqe->immed_rss_invalid) << 24;
>  		skb->ip_summed = ip_summed;
>  		skb->protocol = eth_type_trans(skb, dev);
>  		skb_record_rx_queue(skb, cq->ring);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

