From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 14:49:44 +0300
Message-ID: <20090203114944.GA21957@ioremap.net>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203112431.GA8746@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754010AbZBCLuN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090203112431.GA8746@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 03, 2009 at 10:24:31PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > I even believe that for some hardware it is the only way to deal
> > with the jumbo frames.
> 
> Not necessarily.  Even if the hardware can only DMA into contiguous
> memory, we can always allocate a sufficient number of contiguous
> buffers initially, and then always copy them into fragmented skbs
> at receive time.  This way the contiguous buffers are never
> depleted.

How many such preallocated frames is enough? Does it enough to have all
sockets recv buffer sizes divided by the MTU size? Or just some of them,
or... That will work but there are way too many corner cases.

> Granted copying sucks, but this is really because the underlying
> hardware is badly designed.  Also copying is way better than
> not receiving at all due to memory fragmentation.

Maybe just do not allow jumbo frames when memory is fragmented enough
and fallback to the smaller MTU in this case? With LRO/GRO stuff there
should be not that much of the overhead compared to multiple-page
copies.

-- 
	Evgeniy Polyakov
