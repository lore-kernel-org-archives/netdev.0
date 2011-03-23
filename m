From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] virtio_net: remove send completion interrupts and
 avoid TX queue overrun through packet drop
Date: Tue, 22 Mar 2011 19:26:44 -0700
Message-ID: <1300847204.3441.26.camel@localhost.localdomain>
References: <20110318133311.GA20623@gondor.apana.org.au>
	 <1300498915.3441.21.camel@localhost.localdomain>
	 <1300730587.3441.24.camel@localhost.localdomain>
	 <20110322113649.GA17071@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.hengli.com.au>, rusty@rustcorp.com.au,
	davem@davemloft.net, kvm@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:51536 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755409Ab1CWC0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2011 22:26:48 -0400
In-Reply-To: <20110322113649.GA17071@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-03-22 at 13:36 +0200, Michael S. Tsirkin wrote:
> diff --git a/drivers/virtio/virtio_ring.c
> b/drivers/virtio/virtio_ring.c
> index cc2f73e..6106017 100644
> --- a/drivers/virtio/virtio_ring.c
> +++ b/drivers/virtio/virtio_ring.c
> @@ -185,11 +185,6 @@ int virtqueue_add_buf_gfp(struct virtqueue *_vq,
>         if (vq->num_free < out + in) {
>                 pr_debug("Can't add buf len %i - avail = %i\n",
>                          out + in, vq->num_free);
> -               /* FIXME: for historical reasons, we force a notify
> here if
> -                * there are outgoing parts to the buffer.  Presumably
> the
> -                * host should service the ring ASAP. */
> -               if (out)
> -                       vq->notify(&vq->vq);
>                 END_USE(vq);
>                 return -ENOSPC;
>         }
> 

With simply removing the notify here, it does help the case when TX
overrun hits too often, for example for 1K message size, the single
TCP_STREAM performance improved from 2.xGb/s to 4.xGb/s.

Thanks
Shirley

