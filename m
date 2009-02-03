From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 22:24:31 +1100
Message-ID: <20090203112431.GA8746@gondor.apana.org.au>
References: <20090202080855.GA4129@ff.dom.local> <20090202.001854.261399333.davem@davemloft.net> <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753788AbZBCLZn@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090203111012.GA16878@ioremap.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 03, 2009 at 02:10:12PM +0300, Evgeniy Polyakov wrote:
>
> I even believe that for some hardware it is the only way to deal
> with the jumbo frames.

Not necessarily.  Even if the hardware can only DMA into contiguous
memory, we can always allocate a sufficient number of contiguous
buffers initially, and then always copy them into fragmented skbs
at receive time.  This way the contiguous buffers are never
depleted.

Granted copying sucks, but this is really because the underlying
hardware is badly designed.  Also copying is way better than
not receiving at all due to memory fragmentation.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
