From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: "virtio-net: enable multiqueue by default" in linux-next breaks
 networking on GCE
Date: Mon, 12 Dec 2016 23:19:48 -0500
Message-ID: <20161213041948.lhmdml6vtirc3kz5@thunk.org>
References: <20161212233343.q5xlv55rc5npqaqp@thunk.org>
 <20161213042057-mutt-send-email-mst@kernel.org>
 <20161213031243.avq5g5m5r5ylcnnk@thunk.org>
 <60cd312f-86f9-47e9-0c72-f4c2109e2f87@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
        nhorman@tuxdriver.com, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.thunk.org ([74.207.234.97]:46848 "EHLO imap.thunk.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752867AbcLMETy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 23:19:54 -0500
Content-Disposition: inline
In-Reply-To: <60cd312f-86f9-47e9-0c72-f4c2109e2f87@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 11:43:00AM +0800, Jason Wang wrote:
> Thanks for reporting this issue. Looks like I blindly set the affinity
> instead of queues during probe. Could you please try the following patch to
> see if it works?

This fixed things, thanks!!

						- Ted
						

> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index b425fa1..fe9f772 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -1930,7 +1930,9 @@ static int virtnet_probe(struct virtio_device *vdev)
>                 goto free_unregister_netdev;
>         }
> 
> -       virtnet_set_affinity(vi);
> +       rtnl_lock();
> +       virtnet_set_queues(vi, vi->curr_queue_pairs);
> +       rtnl_unlock();
> 
>         /* Assume link up if device can't report link status,
>            otherwise get link status from config. */
> 
> 
