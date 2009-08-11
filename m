From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH] fix memory leak in virtio_net
Date: Tue, 11 Aug 2009 14:52:58 +0300
Message-ID: <4A815B9A.3060205@redhat.com>
References: <1249934708.7400.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1249934708.7400.10.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(copying Rusty, the virtio maintainer)

On 08/10/2009 11:05 PM, Shirley Ma wrote:
> Whild reading virtio code, I found some memory leak in removing
> virtio_net.
>
> In virtnet_remove, only skb has been freed not the pages in skb
> frags. Here is the patch to fix this, please review it.
>
>    

There were indeed reports of virtio ooming; this might be the cause.

> Signed-off-by: Shirley Ma<xma@us.ibm.com>
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 2a6e81d..7e629d9 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -978,6 +978,7 @@ static void virtnet_remove(struct virtio_device *vdev)
>
>   	/* Free our skbs in send and recv queues, if any. */
>   	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
> +		trim_pages(vi, skb);
>   		kfree_skb(skb);
>   		vi->num--;
>   	}
>
>
>
>
>    


-- 
error compiling committee.c: too many arguments to function

