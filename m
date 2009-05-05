From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 0/3] tun: fix aio
Date: Tue, 5 May 2009 11:40:05 +0300
Message-ID: <20090505084005.GA14527@redhat.com>
References: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com> <200904271048.38401.rusty@rustcorp.com.au> <20090427093455.GA29082@redhat.com> <200905051248.14014.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:37407 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753208AbZEEIlK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 04:41:10 -0400
Content-Disposition: inline
In-Reply-To: <200905051248.14014.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 05, 2009 at 12:48:13PM +0930, Rusty Russell wrote:
> On Mon, 27 Apr 2009 07:04:55 pm Michael S. Tsirkin wrote:
> > On Mon, Apr 27, 2009 at 10:48:37AM +0930, Rusty Russell wrote:
> > > > Sure. Here it is: much smaller, but slightly slower.
> > > 
> > > Which could probably be fixed by using an on-stack version for a iovec
> > > of less than a certain size...
> > 
> > I agree that for large message sizes the malloc would probably be
> > dwarfed by the cost of memory copy. However a large iovec might pass a
> > small message, might it not?
> 
> Sorry, I didn't make myself clear.  Something like:
> 
> 	struct iovec smalliov[512 / sizeof(struct iovec)];
> 
> 	if (count < ARRAY_SIZE(smalliov)) {
> 		iv = smalliov;
> 	} else {
> 		iv = kmalloc(...)
> 	}
> 
> 	...
> 
> 	if (iv != smalliov)
> 		kfree(iv);
> 
> Cheers,
> Rusty.

What I was trying to say is that this special-cases iovecs with count >
64. But I think that such iovecs might be used to still pass around
relatively small messages (theoretically as small as 64 bytes) and then
the overhead of the kmalloc/kfree is noticeable.

-- 
MST
