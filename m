From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next 1/5] net, atm/ambassader: convert skb->tail into
 skb_tail_pointer(skb)
Date: Mon, 17 Jun 2013 11:01:09 +0900
Message-ID: <20130617020109.GB15043@verge.net.au>
References: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Chas Williams <chas@cmf.nrl.navy.mil>
To: Isaku Yamahata <yamahata@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:42452 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663Ab3FQCAH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 22:00:07 -0400
Content-Disposition: inline
In-Reply-To: <bb5cc0b762102c6a6a56bbd2067c7e539abfb2a6.1371200138.git.yamahata@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 14, 2013 at 05:58:31PM +0900, Isaku Yamahata wrote:
> The change set of 27a884dc, "[SK_BUFF]: Convert skb->tail to sk_buff_data_t"
> converted skb->tail from pointer into sk_buff_data_t. It missed skb->tail
> in drivers/atm/ambassador.c.
> This patch converts skb->tail into skb_tail_pointer(skb).
> 
> Found by inspection. Compile tested only.
> 
> Cc: Simon Horman <horms@verge.net.au>
> Cc: Chas Williams <chas@cmf.nrl.navy.mil>
> Signed-off-by: Isaku Yamahata <yamahata@valinux.co.jp>

Reviewed-by: Simon Horman <horms@verge.net.au>

> ---
>  drivers/atm/ambassador.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/atm/ambassador.c b/drivers/atm/ambassador.c
> index 77a7480..62a7607 100644
> --- a/drivers/atm/ambassador.c
> +++ b/drivers/atm/ambassador.c
> @@ -1403,7 +1403,7 @@ static void amb_free_rx_skb (struct atm_vcc * atm_vcc, struct sk_buff * skb) {
>    rx.host_address = cpu_to_be32 (virt_to_bus (skb->data));
>    
>    skb->data = skb->head;
> -  skb->tail = skb->head;
> +  skb_reset_tail_pointer(skb);
>    skb->len = 0;
>    
>    if (!rx_give (dev, &rx, pool)) {
> -- 
> 1.7.10.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
