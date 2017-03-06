From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 3/4] vhost: interrupt coalescing support
Date: Mon, 6 Mar 2017 17:28:07 +0800
Message-ID: <51a3fba2-a789-7bcf-946d-577220865709@redhat.com>
References: <20170303143909.80001-1-willemdebruijn.kernel@gmail.com>
 <20170303143909.80001-4-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: mst@redhat.com, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55746 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752899AbdCFJ2M (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 6 Mar 2017 04:28:12 -0500
In-Reply-To: <20170303143909.80001-4-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年03月03日 22:39, Willem de Bruijn wrote:
> +void vhost_signal(struct vhost_dev *dev, struct vhost_virtqueue *vq);
> +static enum hrtimer_restart vhost_coalesce_timer(struct hrtimer *timer)
> +{
> +	struct vhost_virtqueue *vq =
> +		container_of(timer, struct vhost_virtqueue, ctimer);
> +
> +	if (mutex_trylock(&vq->mutex)) {
> +		vq->coalesce_frames = vq->max_coalesce_frames;
> +		vhost_signal(vq->dev, vq);
> +		mutex_unlock(&vq->mutex);
> +	}
> +
> +	/* TODO: restart if lock failed and not held by handle_tx */
> +	return HRTIMER_NORESTART;
> +}
> +

Then we may lose an interrupt forever if no new tx request? I believe we 
need e.g vhost_poll_queue() here.

Thanks
