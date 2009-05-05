From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 0/3] tun: fix aio
Date: Tue, 5 May 2009 12:48:13 +0930
Message-ID: <200905051248.14014.rusty@rustcorp.com.au>
References: <20090420112527.GA6692@dhcp-1-124.tlv.redhat.com> <200904271048.38401.rusty@rustcorp.com.au> <20090427093455.GA29082@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:53967 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751157AbZEEEY1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2009 00:24:27 -0400
In-Reply-To: <20090427093455.GA29082@redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Apr 2009 07:04:55 pm Michael S. Tsirkin wrote:
> On Mon, Apr 27, 2009 at 10:48:37AM +0930, Rusty Russell wrote:
> > > Sure. Here it is: much smaller, but slightly slower.
> > 
> > Which could probably be fixed by using an on-stack version for a iovec
> > of less than a certain size...
> 
> I agree that for large message sizes the malloc would probably be
> dwarfed by the cost of memory copy. However a large iovec might pass a
> small message, might it not?

Sorry, I didn't make myself clear.  Something like:

	struct iovec smalliov[512 / sizeof(struct iovec)];

	if (count < ARRAY_SIZE(smalliov)) {
		iv = smalliov;
	} else {
		iv = kmalloc(...)
	}

	...

	if (iv != smalliov)
		kfree(iv);

Cheers,
Rusty.
