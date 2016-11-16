From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: add a missing synchronize_net()
Date: Wed, 16 Nov 2016 15:55:46 +0200
Message-ID: <20161116155537-mutt-send-email-mst@kernel.org>
References: <1479277452.8455.156.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>, Jason Wang <jasowang@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58948 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753215AbcKPNzs (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Nov 2016 08:55:48 -0500
Content-Disposition: inline
In-Reply-To: <1479277452.8455.156.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 15, 2016 at 10:24:12PM -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> It seems many drivers do not respect napi_hash_del() contract.
> 
> When napi_hash_del() is used before netif_napi_del(), an RCU grace
> period is needed before freeing NAPI object.
> 
> Fixes: 91815639d880 ("virtio-net: rx busy polling support")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>


> ---
>  drivers/net/virtio_net.c |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index fd8b1e62301f..7276d5a95bd0 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1497,6 +1497,11 @@ static void virtnet_free_queues(struct virtnet_info *vi)
>  		netif_napi_del(&vi->rq[i].napi);
>  	}
>  
> +	/* We called napi_hash_del() before netif_napi_del(),
> +	 * we need to respect an RCU grace period before freeing vi->rq
> +	 */
> +	synchronize_net();
> +
>  	kfree(vi->rq);
>  	kfree(vi->sq);
>  }
> 
