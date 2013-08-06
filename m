From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH for 3.4 1/2] vhost: zerocopy: poll vq in zerocopy callback
Date: Tue, 6 Aug 2013 13:04:38 +0300
Message-ID: <20130806100438.GF11051@redhat.com>
References: <1375781359-5764-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56902 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754631Ab3HFKDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 06:03:01 -0400
Content-Disposition: inline
In-Reply-To: <1375781359-5764-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 06, 2013 at 05:29:18PM +0800, Jason Wang wrote:
> commit c70aa540c7a9f67add11ad3161096fb95233aa2e upstream.
> 
> We add used and signal guest in worker thread but did not poll the virtqueue
> during the zero copy callback. This may lead the missing of adding and
> signalling during zerocopy. Solve this by polling the virtqueue and let it
> wakeup the worker during callback.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/vhost/vhost.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 1a9e2a9..a50cb9c 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1603,6 +1603,7 @@ void vhost_zerocopy_callback(struct ubuf_info *ubuf)
>  	struct vhost_ubuf_ref *ubufs = ubuf->ctx;
>  	struct vhost_virtqueue *vq = ubufs->vq;
>  
> +	vhost_poll_queue(&vq->poll);
>  	/* set len = 1 to mark this desc buffers done DMA */
>  	vq->heads[ubuf->desc].len = VHOST_DMA_DONE_LEN;
>  	kref_put(&ubufs->kref, vhost_zerocopy_done_signal);
> -- 
> 1.7.1
