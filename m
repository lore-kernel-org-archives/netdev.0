From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH v7 01/19] Add a new structure for skb buffer from
	external.
Date: Sun, 20 Jun 2010 15:48:48 +0300
Message-ID: <20100620124848.GE5285@redhat.com>
References: <20100618055929.GA11333@gondor.apana.org.au> <F2E9EB7348B8264F86B6AB8151CE2D7915089FE573@shsmsx502.ccr.corp.intel.com> <20100620100631.GB4578@redhat.com> <20100620103235.GA31284@gondor.apana.org.au> <20100620103909.GA5285@redhat.com> <20100620110254.GA31484@gondor.apana.org.au> <20100620111124.GB5285@redhat.com> <20100620113609.GA31693@gondor.apana.org.au> <20100620114719.GC5285@redhat.com> <20100620115926.GA31849@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Xin, Xiaohui" <xiaohui.xin@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kvm@vger.kernel.org" <kvm@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"jdike@linux.intel.com" <jdike@linux.intel.com>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:13608 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753091Ab0FTMyI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Jun 2010 08:54:08 -0400
Content-Disposition: inline
In-Reply-To: <20100620115926.GA31849@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 20, 2010 at 09:59:26PM +1000, Herbert Xu wrote:
> On Sun, Jun 20, 2010 at 02:47:19PM +0300, Michael S. Tsirkin wrote:
> >
> > Let's do this then.  So far the virtio spec avoided making layout
> > assumptions, leaving guests lay out data as they see fit.
> > Isn't it possible to keep supporting this with zero copy for hardware
> > that can issue DMA at arbitrary addresses?
> 
> I think you're mistaken with respect to what is being proposed.
> Raising 512 bytes isn't a hard constraint, it is merely an
> optimisation for Intel NICs because their PS mode can produce
> a head fragment of up to 512 bytes.
> 
Thanks for the clarification. So what is discussed here is
the API changes that will enable this optimization?
Of couse, it makes sense to consider this to try and avoid code churn
in the future.

As a side note, I hope to see a basic zero copy implementation with
GSO/GRO that beats copy in host convincingly before work is started on
further optimizations, though.

> If the guest didn't allocate 512 bytes it wouldn't be the end of
> the world, it'd just mean that we'd either copy whatever is in
> the head fragment,
I don't know how much will copying the head cost.

> or we waste 4096-X bytes of memory where X
> is the number of bytes in the head.

This seems mostly harmless - and guest can always do a copy internally
to save memory, correct?
Note also that we lock a full page to allow DMA, anyway.

> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
