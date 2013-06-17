From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 4/5] pxa168_eth: convert skb->end into
 skb_end_pointer(skb)
Date: Mon, 17 Jun 2013 11:01:50 +0900
Message-ID: <20130617020150.GC15043@verge.net.au>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
 <e9e0e51be02aec40989c4715466d0142381929fe.1371200138.git.yamahata@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Isaku Yamahata <yamahata@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:42458 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663Ab3FQCAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 22:00:47 -0400
Content-Disposition: inline
In-Reply-To: <e9e0e51be02aec40989c4715466d0142381929fe.1371200138.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 05:58:34PM +0900, Isaku Yamahata wrote:
> The change set of 4305b541, "[SK_BUFF]: Convert skb->end to sk_buff_data_t"
> converted skb->end from pointer type to sk_buff_data_t.
> The pointed value should be accessed via skb_end_pointer().
> 
> Since arm arch doesn't define NET_SKBUFF_DATA_USES_OFFSET,
> skb->end is effectively pointer. So it doesn't cause a real problem.
> But this patch is good for consistency.
> 
> Found by inspection. Compile tested only.
> 
> Cc: Simon Horman <horms@verge.net.au>
> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
>  drivers/net/ethernet/marvell/pxa168_eth.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
> index 2602cf7..ec20508 100644
> --- a/drivers/net/ethernet/marvell/pxa168_eth.c
> +++ b/drivers/net/ethernet/marvell/pxa168_eth.c
> @@ -357,7 +357,7 @@ static void rxq_refill(struct net_device *dev)
>  		/* Get 'used' Rx descriptor */
>  		used_rx_desc = pep->rx_used_desc_q;
>  		p_used_rx_desc = &pep->p_rx_desc_area[used_rx_desc];
> -		size = skb->end - skb->data;
> +		size = skb_end_pointer(skb) - skb->data;
>  		p_used_rx_desc->buf_ptr = dma_map_single(NULL,
>  							 skb->data,
>  							 size,
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
