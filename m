From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH] Regression in linux 2.6.32 virtio_net seen with
	vhost-net
Date: Wed, 16 Dec 2009 01:32:27 +0200
Message-ID: <20091215233226.GA27129@redhat.com>
References: <1260312605.19229.8.camel@w-sridhar.beaverton.ibm.com> <20091213122512.GA17255@gondor.apana.org.au> <20091213234055.GA28340@redhat.com> <20091215144252.GA7465@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sridhar Samudrala <sri@us.ibm.com>, rusty@rustcorp.com.au,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760681AbZLOXfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2009 18:35:50 -0500
Content-Disposition: inline
In-Reply-To: <20091215144252.GA7465@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 15, 2009 at 10:42:52PM +0800, Herbert Xu wrote:
> On Mon, Dec 14, 2009 at 01:40:55AM +0200, Michael S. Tsirkin wrote:
> >
> > An interesting thing is that
> > 48925e372f04f5e35fec6269127c62b2c71ab794
> > was supposed to do this already.
> 
> But Rusty missed the queue wake call.  That too needs to check
> that the required amount of space exists.

Right. Hmm. So for this to work we'll need to
1. Free skb upon interrupt instead of
   waiting for the next xmit call
2. Add API to query free ring capacity

Rusty, sounds like a good plan?

We could also extend host to delay interrupt
until there is sufficient TX capacity
but of course we also need to support
old hosts as well.


> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
