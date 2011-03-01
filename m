From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 05:19:55 -0500
Message-ID: <20110301101955.GI9763@canuck.infradead.org>
References: <20110225.112019.48513284.davem@davemloft.net>
 <20110226005718.GA19889@gondor.apana.org.au>
 <20110227110205.GE9763@canuck.infradead.org>
 <20110227110614.GA6246@gondor.apana.org.au>
 <20110228113659.GA20726@gondor.apana.org.au>
 <20110228141322.GF9763@canuck.infradead.org>
 <1298910174.2941.585.camel@edumazet-laptop>
 <20110228163742.GH9763@canuck.infradead.org>
 <1298912869.2941.687.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:47687 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754642Ab1CAKUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 05:20:01 -0500
Content-Disposition: inline
In-Reply-To: <1298912869.2941.687.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 28, 2011 at 06:07:49PM +0100, Eric Dumazet wrote:
> > The numbers differ a lot depending on the architecture we test on.
> > 
> > F.e. on a 12 core AMD with 2 NUMA nodes:
> > 
> > 2.6.32   named -n 1: 37.0kqps
> >          named:       3.8kqps (yes, no joke, the socket receive buffer is
> >                                always full and the kernel drops pkts)
> 
> Yes, this old kernel miss commit c377411f2494a93 added in 2.6.35
> (net: sk_add_backlog() take rmem_alloc into account)

I retested with net-2.6 w/o Herbert's patch:

named -n 1: 36.9kqps
named:      16.2kqps

> > 2.6.38-rc5+ with Herbert's patches:
> >         named -n 1:  36.9kqps
> >         named:      222.0kqps
