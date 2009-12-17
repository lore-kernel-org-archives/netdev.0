From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Thu, 17 Dec 2009 22:36:35 +0800
Message-ID: <20091217143635.GA388@gondor.apana.org.au>
References: <OFA4DBC95B.29C84EEB-ON6525768F.0035A704-6525768F.003644A9@in.ibm.com> <20091217112754.GA7755@ff.dom.local> <20091217114535.GA30429@gondor.apana.org.au> <20091217114937.GA30503@gondor.apana.org.au> <20091217120856.GA30774@gondor.apana.org.au> <OF4408981E.ACFC27B2-ON6525768F.0042EA92-6525768F.00436345@in.ibm.com> <20091217134408.GB31964@gondor.apana.org.au> <OF6A94FA41.B9EF2995-ON6525768F.004B99AC-6525768F.004F1634@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>, mst@redhat.com,
	netdev@vger.kernel.org, Rusty Russell <rusty@rustcorp.com.au>,
	Sridhar Samudrala <sri@us.ibm.com>
To: Krishna Kumar2 <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37421 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965018AbZLQOgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 09:36:45 -0500
Content-Disposition: inline
In-Reply-To: <OF6A94FA41.B9EF2995-ON6525768F.004B99AC-6525768F.004F1634@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 08:05:02PM +0530, Krishna Kumar2 wrote:
>
> I think the bug is in this check:
> 
> +     if (vi->capacity >= 2 + MAX_SKB_FRAGS) {
> +           /* Suppress further xmit interrupts. */
> +           vi->svq->vq_ops->disable_cb(vi->svq);
> +           napi_complete(xmit_napi);
> +
> +           /* Don't wake it if link is down. */
> +           if (likely(netif_carrier_ok(vi->vdev)))
> +                 netif_wake_queue(vi->dev);
> +     }
> 
> We wake up too fast, just enough space for one more skb to be sent
> before the queue is stopped again. And hence no more messages about
> queue full, but lot of requeues. The qdisc code is doing the correct
> thing, but we need to increase the limit here.
> 
> Can we try with some big number, 64, 128?

Good point.  Sridhar, could you please test doubling or quadrupling
the threshold? 128 is probably a bit too much though as the ring
only has 256 entries.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
