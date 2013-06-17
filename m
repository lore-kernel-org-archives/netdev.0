From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 5/5] staging/rtl8192u: convert skb->tail into
 skb_tail_pointer(skb)
Date: Mon, 17 Jun 2013 11:03:05 +0900
Message-ID: <20130617020305.GE15043@verge.net.au>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
 <4e2318187b15be4d81c3b03cd0337506c7008bb8.1371200138.git.yamahata@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	devel@driverdev.osuosl.org
To: Isaku Yamahata <yamahata@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:42468 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754412Ab3FQCCD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 22:02:03 -0400
Content-Disposition: inline
In-Reply-To: <4e2318187b15be4d81c3b03cd0337506c7008bb8.1371200138.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 05:58:35PM +0900, Isaku Yamahata wrote:
> The change set of 7a884dc "[SK_BUFF]: Convert skb->tail to sk_buff_data_t"
> converted skb->tail from pointer into sk_buff_data_t.
> Thus skb->tail is not always pointer, the area pointed by skb->tail
> should be accessed via skb_tail_pointer().
> 
> Found by inspection. Compile tested only.
> 
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: devel@driverdev.osuosl.org
> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
>  drivers/staging/rtl8192u/r8192U_core.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/staging/rtl8192u/r8192U_core.c b/drivers/staging/rtl8192u/r8192U_core.c
> index 71f5cde..a18430e 100644
> --- a/drivers/staging/rtl8192u/r8192U_core.c
> +++ b/drivers/staging/rtl8192u/r8192U_core.c
> @@ -1271,8 +1271,8 @@ struct sk_buff *DrvAggr_Aggregation(struct net_device *dev, struct ieee80211_drv
>  		/* Subframe drv Tx descriptor and firmware info setting */
>  		skb = pSendList->tx_agg_frames[i];
>  		tcb_desc = (cb_desc *)(skb->cb + MAX_DEV_ADDR_SIZE);
> -		tx_agg_desc = (tx_desc_819x_usb_aggr_subframe *)agg_skb->tail;
> -		tx_fwinfo = (tx_fwinfo_819x_usb *)(agg_skb->tail + sizeof(tx_desc_819x_usb_aggr_subframe));
> +		tx_agg_desc = (tx_desc_819x_usb_aggr_subframe *)skb_tail_pointer(agg_skb);
> +		tx_fwinfo = (tx_fwinfo_819x_usb *)(skb_tail_pointer(agg_skb) + sizeof(tx_desc_819x_usb_aggr_subframe));
>  
>  		memset(tx_fwinfo,0,sizeof(tx_fwinfo_819x_usb));
>  		/* DWORD 0 */
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
