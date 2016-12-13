From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] virtio-net: correctly enable multiqueue
Date: Tue, 13 Dec 2016 15:56:46 +0200
Message-ID: <20161213155142-mutt-send-email-mst@kernel.org>
References: <1481610185-12183-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
        tytso@mit.edu, Neil Horman <nhorman@tuxdriver.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33792 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933114AbcLMN4r (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Dec 2016 08:56:47 -0500
Content-Disposition: inline
In-Reply-To: <1481610185-12183-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 02:23:05PM +0800, Jason Wang wrote:
> Commit 4490001029012539937ff02778fe6180613fa949 ("virtio-net: enable
> multiqueue by default") blindly set the affinity instead of queues
> during probe which can cause a mismatch of #queues between guest and
> host. This patch fixes it by setting queues.
> 
> Reported-by: Theodore Ts'o <tytso@mit.edu>
> Tested-by: Theodore Ts'o <tytso@mit.edu>
> Cc: Neil Horman <nhorman@tuxdriver.com>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Fixes: 49000102901 ("virtio-net: enable multiqueue by default")
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index b425fa1..fe9f772 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1930,7 +1930,9 @@ static int virtnet_probe(struct virtio_device *vdev)
>  		goto free_unregister_netdev;
>  	}
>  
> -	virtnet_set_affinity(vi);
> +	rtnl_lock();
> +	virtnet_set_queues(vi, vi->curr_queue_pairs);
> +	rtnl_unlock();
>  
>  	/* Assume link up if device can't report link status,
>  	   otherwise get link status from config. */

I note that virtnet_set_channels also plays with affinity
directly. Can this be changed to rely on cpu notifiers
somehow?


> -- 
> 2.7.4
