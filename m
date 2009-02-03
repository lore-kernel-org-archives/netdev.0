From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 3 Feb 2009 23:33:12 +1100
Message-ID: <200902032333.15525.nickpiggin@yahoo.com.au>
References: <20090202080855.GA4129@ff.dom.local> <20090203121219.GB22427@ioremap.net> <20090203121808.GA9218@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <zbr@ioremap.net>, david@lang.hm,
	Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, w@1wt.eu,
	dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp105.mail.mud.yahoo.com ([209.191.85.215]:45074 "HELO
	smtp105.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752811AbZBCMdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 07:33:41 -0500
In-Reply-To: <20090203121808.GA9218@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 03 February 2009 23:18:08 Herbert Xu wrote:
> On Tue, Feb 03, 2009 at 03:12:19PM +0300, Evgeniy Polyakov wrote:
> > It is a solution, but I think it will behave noticebly worse than
> > with decresed MTU.
>
> Not necessarily.  Remember GSO/GRO in essence are just hacks to
> get around the fact that we can't increase the MTU to where we
> want it to be.  MTU reduces the cost over the entire path while
> GRO/GSO only do so for the sender and the receiver.
>
> In other words when given the choice between a larger MTU with
> copying or GRO, the larger MTU will probably win anyway as it's
> optimising the entire path rather than just the receiver.
>
> > That's the main point: how to deal with broken hardware? I think (but
> > have no strong numbers though) that having 6 packets with 1500 MTU
> > combined into GRO/LRO frame will be processed way faster than copying 9k
> > MTU into 3 pages and process single skb.
>
> Please note that with my scheme, you'd only start copying if you
> can't allocate a linear skb.  So if memory fragmentation doesn't
> happen then there is no copying at all.

This sounds like a really nice idea (to the layman)!

