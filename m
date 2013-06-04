From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next] cxgb3: Correct comparisons and calculations
 using skb->tail and skb-transport_header
Date: Tue, 4 Jun 2013 22:23:53 +0900
Message-ID: <20130604132353.GF3068@verge.net.au>
References: <1370333476-17699-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:37955 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751418Ab3FDNX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 09:23:56 -0400
Content-Disposition: inline
In-Reply-To: <1370333476-17699-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 04, 2013 at 04:11:16PM +0800, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> This corrects an regression introduced by "net: Use 16bits for *_headers
> fields of struct skbuff" when NET_SKBUFF_DATA_USES_OFFSET is not set. In
> that case skb->tail will be a pointer whereas skb->transport_header
> will be an offset from head. This is corrected by using wrappers that
> ensure that comparisons and calculations are always made using pointers.
> 
> Cc: Simon Horman <horms@verge.net.au>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
>  drivers/net/ethernet/chelsio/cxgb3/sge.c |    2 +-
>  drivers/net/ethernet/chelsio/cxgb4/sge.c |    2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
> index 46d1efc..687ec4a 100644
> --- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
> +++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
> @@ -1583,7 +1583,7 @@ static void deferred_unmap_destructor(struct sk_buff *skb)
>  	dui = (struct deferred_unmap_info *)skb->head;
>  	p = dui->addr;
>  
> -	if (skb->tail - skb->transport_header)
> +	if (skb_tail_pointer(skb) - skb_transport_header(skb))
>  		pci_unmap_single(dui->pdev, *p++, skb_tail_pointer(skb) -
>  				 skb_transport_header(skb), PCI_DMA_TODEVICE);
>  
> diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
> index 2bfbb20..ac311f5 100644
> --- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
> +++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
> @@ -1294,7 +1294,7 @@ static inline unsigned int calc_tx_flits_ofld(const struct sk_buff *skb)
>  
>  	flits = skb_transport_offset(skb) / 8U;   /* headers */
>  	cnt = skb_shinfo(skb)->nr_frags;
> -	if (skb->tail != skb->transport_header)
> +	if (skb_tail_pointer(skb) != skb_transport_header(skb))
>  		cnt++;
>  	return flits + sgl_len(cnt);
>  }
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
