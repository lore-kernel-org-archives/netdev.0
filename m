From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH] sgi-xp: fix a use after free
Date: Sun, 19 Jun 2011 21:44:56 -0500
Message-ID: <20110620024455.GF3525@sgi.com>
References: <1308523956.3539.105.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Robin Holt <holt@sgi.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.sgi.com ([192.48.179.30]:37179 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750878Ab1FTCo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2011 22:44:57 -0400
Content-Disposition: inline
In-Reply-To: <1308523956.3539.105.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thank you Eric.

David, if you want me to submit this through Andrew Morton, I can do
that instead.


Acked-by: Robin Holt <holt@sgi.com>


On Mon, Jun 20, 2011 at 12:52:36AM +0200, Eric Dumazet wrote:
> Its illegal to dereference skb after dev_kfree_skb(skb)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Robin Holt <holt@sgi.com>
> ---
> David, I am not sure Robin is active these days, maybe you can take this
> patch, since its clearly network related ?
> 
>  drivers/misc/sgi-xp/xpnet.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/misc/sgi-xp/xpnet.c b/drivers/misc/sgi-xp/xpnet.c
> index ee5109a..42f0673 100644
> --- a/drivers/misc/sgi-xp/xpnet.c
> +++ b/drivers/misc/sgi-xp/xpnet.c
> @@ -495,14 +495,14 @@ xpnet_dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  		}
>  	}
>  
> +	dev->stats.tx_packets++;
> +	dev->stats.tx_bytes += skb->len;
> +
>  	if (atomic_dec_return(&queued_msg->use_count) == 0) {
>  		dev_kfree_skb(skb);
>  		kfree(queued_msg);
>  	}
>  
> -	dev->stats.tx_packets++;
> -	dev->stats.tx_bytes += skb->len;
> -
>  	return NETDEV_TX_OK;
>  }
>  
> 
