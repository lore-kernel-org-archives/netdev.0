From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 4/4] forcedeth: add transmit timestamping support
Date: Sat, 28 Apr 2012 09:49:45 +0200
Message-ID: <1335599385.2900.53.camel@edumazet-glaptop>
References: <1335553447-11964-1-git-send-email-willemb@google.com>
	 <1335553447-11964-5-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	jeffrey.t.kirscher@intel.com, eilong@broadcom.com,
	aabdulla@nvidia.com
To: Willem de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:53589 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750838Ab2D1Hts (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 03:49:48 -0400
Received: by wgbdr13 with SMTP id dr13so1427129wgb.1
        for <netdev@vger.kernel.org>; Sat, 28 Apr 2012 00:49:47 -0700 (PDT)
In-Reply-To: <1335553447-11964-5-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-04-27 at 15:04 -0400, Willem de Bruijn wrote:
> Insert an skb_tx_timestamp call in both ndo_start_xmit routines
> Tested to work for the nv_start_xmit_optimized case
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>  drivers/net/ethernet/nvidia/forcedeth.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
> index d93a088..928913c 100644
> --- a/drivers/net/ethernet/nvidia/forcedeth.c
> +++ b/drivers/net/ethernet/nvidia/forcedeth.c
> @@ -2279,6 +2279,8 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  
>  	netdev_sent_queue(np->dev, skb->len);
>  
> +	skb_tx_timestamp(skb);
> +
>  	np->put_tx.orig = put_tx;
>  
>  	spin_unlock_irqrestore(&np->lock, flags);
> @@ -2426,6 +2428,8 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
>  
>  	netdev_sent_queue(np->dev, skb->len);
>  
> +	skb_tx_timestamp(skb);
> +
>  	np->put_tx.ex = put_tx;
>  
>  	spin_unlock_irqrestore(&np->lock, flags);

Acked-by: Eric Dumazet <edumazet@google.com>
