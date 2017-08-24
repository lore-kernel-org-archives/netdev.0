From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio_net: be drop monitor friend
Date: Fri, 25 Aug 2017 00:42:58 +0300
Message-ID: <20170825004250-mutt-send-email-mst@kernel.org>
References: <1503590569.2499.81.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Jason Wang <jasowang@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58304 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753867AbdHXVnB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 24 Aug 2017 17:43:01 -0400
Content-Disposition: inline
In-Reply-To: <1503590569.2499.81.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 24, 2017 at 09:02:49AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> This change is needed to not fool drop monitor.
> (perf record ... -e skb:kfree_skb )
> 
> Packets were properly sent and are consumed after TX completion.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 98f17b05c68b..b06169ea60dc 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1058,7 +1058,7 @@ static void free_old_xmit_skbs(struct send_queue *sq)
>  		bytes += skb->len;
>  		packets++;
>  
> -		dev_kfree_skb_any(skb);
> +		dev_consume_skb_any(skb);
>  	}
>  
>  	/* Avoid overhead when no packets have been processed
> 
