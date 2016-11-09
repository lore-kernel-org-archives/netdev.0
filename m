From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/3] vhost: better detection of available buffers
Date: Wed, 9 Nov 2016 21:57:13 +0200
Message-ID: <20161109215513-mutt-send-email-mst@kernel.org>
References: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
 <1478677113-13126-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1478677113-13126-2-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 09, 2016 at 03:38:32PM +0800, Jason Wang wrote:
> We should use vq->last_avail_idx instead of vq->avail_idx in the
> checking of vhost_vq_avail_empty() since latter is the cached avail
> index from guest but we want to know if there's pending available
> buffers in the virtqueue.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

I'm not sure why is this patch here. Is it related to
batching somehow?


> ---
>  drivers/vhost/vhost.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index c6f2d89..fdf4cdf 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -2230,7 +2230,7 @@ bool vhost_vq_avail_empty(struct vhost_dev *dev, struct vhost_virtqueue *vq)
>  	if (r)
>  		return false;
>  
> -	return vhost16_to_cpu(vq, avail_idx) == vq->avail_idx;
> +	return vhost16_to_cpu(vq, avail_idx) == vq->last_avail_idx;
>  }
>  EXPORT_SYMBOL_GPL(vhost_vq_avail_empty);

That might be OK for TX but it's probably wrong for RX
where the fact that used != avail does not mean
we have enough space to store the packet.

Maybe we should just rename this to vhost_vq_avail_unchanged
to clarify usage.


>  
> -- 
> 2.7.4
