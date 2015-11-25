From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: KASAN failures in X-Gene ethernet driver in v4.4-rc2
Date: Wed, 25 Nov 2015 16:34:02 +0000
Message-ID: <20151125163402.GA29094@leverpostej>
References: <20151125155753.GE12434@leverpostej>
 <1448468256.24696.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, isubramanian@apm.com, kchudgar@apm.com,
	linux-kernel@vger.kernel.org, ryabinin.a.a@gmail.com,
	linux-arm-kernel@lists.infradead.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448468256.24696.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 25, 2015 at 08:17:36AM -0800, Eric Dumazet wrote:
> On Wed, 2015-11-25 at 15:59 +0000, Mark Rutland wrote:
> > xgene_enet_start_xmit
> 
> Please try following trivial fix

With that applied KASAN is silent, despite my efforts to trigger the
issue, so it looks like that fixes it.

Thanks,
Mark.

> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> index 1adfe7036843..9147a0107c44 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
> @@ -450,12 +450,12 @@ static netdev_tx_t xgene_enet_start_xmit(struct sk_buff *skb,
>  		return NETDEV_TX_OK;
>  	}
>  
> -	pdata->ring_ops->wr_cmd(tx_ring, count);
>  	skb_tx_timestamp(skb);
>  
>  	pdata->stats.tx_packets++;
>  	pdata->stats.tx_bytes += skb->len;
>  
> +	pdata->ring_ops->wr_cmd(tx_ring, count);
>  	return NETDEV_TX_OK;
>  }
>  
> 
> 
