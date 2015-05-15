From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC 08/23] net/xen-netback: Remove unused code in
 xenvif_rx_action
Date: Fri, 15 May 2015 01:26:37 +0100
Message-ID: <20150515002637.GD19352@zion.uk.xensource.com>
References: <1431622863-28575-1-git-send-email-julien.grall@citrix.com>
 <1431622863-28575-9-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	<tim@xen.org>, Wei Liu <wei.liu2@citrix.com>,
	<netdev@vger.kernel.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1431622863-28575-9-git-send-email-julien.grall@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 14, 2015 at 06:00:48PM +0100, Julien Grall wrote:
> The variables old_req_cons and ring_slots_used are assigned but never
> used since commit 1650d5455bd2dc6b5ee134bd6fc1a3236c266b5b "xen-netback:
> always fully coalesce guest Rx packets".
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: netdev@vger.kernel.org

Acked-by: Wei Liu <wei.liu2@citrix.com>

> ---
>  drivers/net/xen-netback/netback.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 9c6a504..9ae1d43 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -515,14 +515,9 @@ static void xenvif_rx_action(struct xenvif_queue *queue)
>  
>  	while (xenvif_rx_ring_slots_available(queue, XEN_NETBK_RX_SLOTS_MAX)
>  	       && (skb = xenvif_rx_dequeue(queue)) != NULL) {
> -		RING_IDX old_req_cons;
> -		RING_IDX ring_slots_used;
> -
>  		queue->last_rx_time = jiffies;
>  
> -		old_req_cons = queue->rx.req_cons;
>  		XENVIF_RX_CB(skb)->meta_slots_used = xenvif_gop_skb(skb, &npo, queue);
> -		ring_slots_used = queue->rx.req_cons - old_req_cons;
>  
>  		__skb_queue_tail(&rxq, skb);
>  	}
> -- 
> 2.1.4
