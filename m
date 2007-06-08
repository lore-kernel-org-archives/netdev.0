From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [PATCH][RFC] network splice receive
Date: Fri, 8 Jun 2007 12:56:20 +0400
Message-ID: <20070608085620.GC11488@2ka.mipt.ru>
References: <20070607105159.GV4735@kernel.dk> <20070607145818.GA26491@2ka.mipt.ru> <20070608074823.GG7341@kernel.dk> <20070608.010629.52902577.davem@davemloft.net> <20070608083853.GH7341@kernel.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:50065 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966686AbXFHI5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jun 2007 04:57:09 -0400
Content-Disposition: inline
In-Reply-To: <20070608083853.GH7341@kernel.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 08, 2007 at 10:38:53AM +0200, Jens Axboe (jens.axboe@oracle.com) wrote:
> On Fri, Jun 08 2007, David Miller wrote:
> > From: Jens Axboe <jens.axboe@oracle.com>
> > Date: Fri, 8 Jun 2007 09:48:24 +0200
> > 
> > > Perhaps it's possible to solve this at a different level - can we hang
> > > on to the skb until the pipe buffer has been consumed, and prevent reuse
> > > that way? Then we don't have to care what backing the skb has, as long
> > > as it (and its data) isn't being reused until we drop the reference to
> > > it in sock_pipe_buf_release().
> > 
> > Depending upon whether the pipe buffer consumption is bounded of not,
> > this will jam up the TCP sender because the SKB data allocation is
> > charged against the socket send buffer allocation.
> 
> Forgive my network ignorance, but is that a problem? Since you bring it
> up, I guess so :-)

David means, that socket bufer allocation is limited, and delaying
freeing can end up with exhausint that limit.

> We can grow the pipe, should we have to. So instead of blocking waiting
> on reader consumption, we can extend the size of the pipe and keep
> going.

I have a code, which roughly works (but I will test it some more), which
just introduces reference counters for slab pages, so that the would not
be actually freed via page reclaim, but only after reference counters
are dropped. That forced changes in mm/slab.c so likely it is
unacceptible solution, but it is interesting as is.

> -- 
> Jens Axboe

-- 
	Evgeniy Polyakov
