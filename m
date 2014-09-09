From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] sfc: Convert the normal transmit complete path
 to dev_consume_skb_any()
Date: Tue, 09 Sep 2014 16:18:24 -0700
Message-ID: <1410304704.7106.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140909214327.D474F290042C@tardy>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, sshah@solarflare.com,
	linux-net-drivers@solarflare.com
To: Rick Jones <raj@tardy.usa.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34256 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906AbaIIXS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2014 19:18:26 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so5078532pab.29
        for <netdev@vger.kernel.org>; Tue, 09 Sep 2014 16:18:25 -0700 (PDT)
In-Reply-To: <20140909214327.D474F290042C@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-09-09 at 14:43 -0700, Rick Jones wrote:
> From: Rick Jones <rick.jones2@hp.com>
> 
> Convert the normal transmit completion path from dev_kfree_skb_any()
> to dev_consume_skb_any() to help keep dropped packet profiling
> meaningful.
> 
> Signed-off-by: Rick Jones <rick.jones2@hp.com>
> 
> ---
> 
> Compile tested only.  Also a fixup to make scripts/checkpatch.pl
> happy.
> 
> diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
> index 65c220f..3206098 100644
> --- a/drivers/net/ethernet/sfc/tx.c
> +++ b/drivers/net/ethernet/sfc/tx.c
> @@ -78,7 +78,7 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
>  	if (buffer->flags & EFX_TX_BUF_SKB) {
>  		(*pkts_compl)++;
>  		(*bytes_compl) += buffer->skb->len;
> -		dev_kfree_skb_any((struct sk_buff *) buffer->skb);
> +		dev_consume_skb_any((struct sk_buff *)buffer->skb);
>  		netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
>  			   "TX queue %d transmission id %x complete\n",
>  			   tx_queue->queue, tx_queue->read_count);

Right, but please remove this ugly cast while you are at it ;)
