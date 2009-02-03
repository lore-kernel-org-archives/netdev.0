From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 13:25:35 +0100
Message-ID: <20090203122535.GB8633@1wt.eu>
References: <20090202084358.GB4129@ff.dom.local> <20090202.235017.253437221.davem@davemloft.net> <20090203094108.GA4639@ff.dom.local> <20090203111012.GA16878@ioremap.net> <20090203112431.GA8746@gondor.apana.org.au> <20090203114944.GA21957@ioremap.net> <20090203115313.GA9018@gondor.apana.org.au> <20090203120715.GA22427@ioremap.net> <20090203121209.GA9154@gondor.apana.org.au> <20090203121836.GA23300@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, dada1@cosmosbay.com,
	ben@zeus.com, mingo@elte.hu, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1958 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752430AbZBCM0L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2009 07:26:11 -0500
Content-Disposition: inline
In-Reply-To: <20090203121836.GA23300@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 03, 2009 at 03:18:36PM +0300, Evgeniy Polyakov wrote:
> On Tue, Feb 03, 2009 at 11:12:09PM +1100, Herbert Xu (herbert@gondor.apana.org.au) wrote:
> > The only change we need to make is at receive time.  Instead of
> > always pushing the received skb into the stack, we should try to
> > allocate a linear replacement skb, and if that fails, allocate
> > a fragmented skb and copy the data into it.  That way we can
> > always push a linear skb back into the ring buffer.
> 
> Yes, that's was the part about 'reserve' buffer for the sockets you cut
> :)
> 
> I agree that this will work and will be better than nothing, but copying
> 9kb into 3 pages is rather CPU hungry operation, and I think (but have
> no numbers though) that system will behave faster if MTU is reduced to
> the standard one.

Well, FWIW, I've always observed better performance with 4k MTU (4080 to
be precise) than with 9K, and I think that the overhead of allocating 3
contiguous pages is a major reason for this.

> Another solution is to have a proper allocator which will be able to
> defragment the data, if talking about the alternatives to the drop.
>
> So:
> 1. copy the whole jumbo skb into fragmented one
> 2. reduce the MTU

you'll not reduce MTU of established connections though. And trying to
advertise MSS changes in the middle of a TCP connection is an awful
hack which I think will not work everywhere.

> 3. rely on the allocator
> 
> For the 'good' hardware and drivers nothing from the above is really needed.
> 
> -- 
> 	Evgeniy Polyakov

Willy

