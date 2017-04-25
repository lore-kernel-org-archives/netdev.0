From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next v3 2/5] virtio-net: transmit napi
Date: Tue, 25 Apr 2017 16:36:57 +0800
Message-ID: <2c5491c0-4473-75d1-fa0f-a0dbd4dc626d@redhat.com>
References: <20170424174930.82623-1-willemdebruijn.kernel@gmail.com>
 <20170424174930.82623-3-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mst@redhat.com, virtualization@lists.linux-foundation.org,
        davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38308 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S980909AbdDYIhF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 04:37:05 -0400
In-Reply-To: <20170424174930.82623-3-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年04月25日 01:49, Willem de Bruijn wrote:
> @@ -1371,8 +1419,10 @@ static int virtnet_close(struct net_device *dev)
>   	/* Make sure refill_work doesn't re-enable napi! */
>   	cancel_delayed_work_sync(&vi->refill);
>   
> -	for (i = 0; i < vi->max_queue_pairs; i++)
> +	for (i = 0; i < vi->max_queue_pairs; i++) {
>   		napi_disable(&vi->rq[i].napi);
> +		napi_disable(&vi->sq[i].napi);
> +	}

Looks like this will wait for ever if napi_tx is false because we never 
enable the NAPI so we will wait for NAPI_STATE_SCHED to be cleared.

Thanks
