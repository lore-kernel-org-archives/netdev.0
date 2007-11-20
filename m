From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 1/2] virtio: fix net driver loop case where we fail to restart
Date: Tue, 20 Nov 2007 16:20:55 +0900
Message-ID: <20071120072053.GF10490@verge.net.au>
References: <200711191120.15596.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lguest <lguest@ozlabs.org>,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:44693 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754242AbXKTHU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 02:20:58 -0500
Content-Disposition: inline
In-Reply-To: <200711191120.15596.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 11:20:15AM +1100, Rusty Russell wrote:
> skb is only NULL the first time around: it's more correct to test for
> being under-budget.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

That looks better to me.

Acked-by: Simon Horman <horms@verge.net.au>

> diff -r 2a94425ac7d5 drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c	Thu Nov 15 13:47:28 2007 +1100
> +++ b/drivers/net/virtio_net.c	Thu Nov 15 23:10:44 2007 +1100
> @@ -198,8 +198,8 @@ again:
>  	if (vi->num < vi->max / 2)
>  		try_fill_recv(vi);
>  
> -	/* All done? */
> -	if (!skb) {
> +	/* Out of packets? */
> +	if (received < budget) {
>  		netif_rx_complete(vi->dev, napi);
>  		if (unlikely(!vi->rvq->vq_ops->restart(vi->rvq))
>  		    && netif_rx_reschedule(vi->dev, napi))
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Horms

