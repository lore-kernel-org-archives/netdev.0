From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net 2/2] rhashtable: remove indirection for grow/shrink
 decision functions
Date: Thu, 12 Mar 2015 16:57:33 +0000
Message-ID: <20150312165733.GB11089@casper.infradead.org>
References: <1424886096.5565.104.camel@edumazet-glaptop2.roam.corp.google.com>
 <20150311064241.GA7153@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, daniel@iogearbox.net,
	David.Laight@aculab.com, davem@davemloft.net, pablo@netfilter.org,
	johunt@akamai.com, kaber@trash.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:51277 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964781AbbCLQ5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 12:57:38 -0400
Content-Disposition: inline
In-Reply-To: <20150311064241.GA7153@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/15 at 05:42pm, Herbert Xu wrote:
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > There is no need to track number of elements, using either an atomic_t
> > or percpu_counter. This adds unnecessary burden.
> > 
> > 1) Automatic shrinking is a non issue. This will free very little
> > memory, compared to previous peak usage (including objects put in
> > rhashtable). If hash grown to a certain point, it's likely it will grow
> > again later.
> > 
> > 2) Growing can be triggered when any bucket has more than X elems, and
> > that is given for free at insert time.
> > X could be log2(buckets)/2 I guess. (aka shift/2)
> > 
> > A global limit on number of elements should be controlled by rhashtable
> > users - if needed -, not in the rhashtable itself.
> 
> I agree in the strongest terms :)

I agree that the max elements should be enforced by users as done by
Netlink right now. I'm also fine with ditching nelems from rhashtable
as long as shrinking is covered. Patrick mentioned several times by
now that nft sets want to have shrinking.
