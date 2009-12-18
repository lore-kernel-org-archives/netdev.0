From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with vhost-net
Date: Fri, 18 Dec 2009 12:25:33 +1030
Message-ID: <200912181225.33936.rusty@rustcorp.com.au>
References: <20091213122512.GA17255@gondor.apana.org.au> <200912171232.26743.rusty@rustcorp.com.au> <20091217092531.GA4905@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Sridhar Samudrala <sri@us.ibm.com>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:40480 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750860AbZLRBzm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 20:55:42 -0500
In-Reply-To: <20091217092531.GA4905@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Dec 2009 07:55:31 pm Michael S. Tsirkin wrote:
> > +static int virtnet_xmit_poll(struct napi_struct *xmit_napi, int budget)
> > +{
> > +	struct virtnet_info *vi =
> > +		container_of(xmit_napi, struct virtnet_info, xmit_napi);
> > +
> > +	/* Don't access vq/capacity at same time as start_xmit. */
> > +	__netif_tx_lock(netdev_get_tx_queue(vi->dev, 0), smp_processor_id());
> 
> So now that we are locking, we could build a variant of this
> without NAPI (maybe with trylock: we can't spin on xmit lock from
> from hard irq context, can we?)? Possibly, if we do, that would be
> a small enough change to be applicable in 2.6.32.

We'd need a separate lock and irq disable; it's not obvious to me that
trylock would never cause us to miss a required wakeup.

I'd rather get this right and backport, than introduce YA random change.
The NAPI change is no more complex that this.

>From what Sridhar has said, this doesn't even fix the issue.  I'm confused...

Rusty.
