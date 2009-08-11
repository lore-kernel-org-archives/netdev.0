From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH] fix memory leak in virtio_net
Date: Mon, 10 Aug 2009 22:03:41 -0700
Message-ID: <1249967021.4161.2.camel@localhost.localdomain>
References: <1249934708.7400.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: kvm@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751222AbZHKLxQ@vger.kernel.org>
In-Reply-To: <1249934708.7400.10.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is false report. I checked kfree_skb(), it does free all pages 
in the fraglist in skb_release_data() later.

Thanks
Shirley

On Mon, 2009-08-10 at 13:05 -0700, Shirley Ma wrote:
> Whild reading virtio code, I found some memory leak in removing
> virtio_net.
> 
> In virtnet_remove, only skb has been freed not the pages in skb
> frags. Here is the patch to fix this, please review it.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 2a6e81d..7e629d9 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -978,6 +978,7 @@ static void virtnet_remove(struct virtio_device *vdev)
> 
>  	/* Free our skbs in send and recv queues, if any. */
>  	while ((skb = __skb_dequeue(&vi->recv)) != NULL) {
> +		trim_pages(vi, skb);
>  		kfree_skb(skb);
>  		vi->num--;
>  	}
> 
> 
> 
> 
