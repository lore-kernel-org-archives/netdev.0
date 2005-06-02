From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] shaper.c: fix locking
Date: Thu, 02 Jun 2005 16:36:28 -0700 (PDT)
Message-ID: <20050602.163628.01205145.davem@davemloft.net>
References: <20050527115450.GA19469@lst.de>
	<20050531.144114.78710204.davem@davemloft.net>
	<20050601052149.GA11935@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hch@lst.de
In-Reply-To: <20050601052149.GA11935@lst.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch@lst.de>
Date: Wed, 1 Jun 2005 07:21:50 +0200

> On Tue, May 31, 2005 at 02:41:14PM -0700, David S. Miller wrote:
> > From: Christoph Hellwig <hch@lst.de>
> > Subject: [PATCH] shaper.c: fix locking
> > Date: Fri, 27 May 2005 13:54:50 +0200
> > 
> > >  o use a semaphore instead of an opencoded and racy lock
> > >  o move locking out of shaper_kick and into the callers - most just
> > >    released the lock before calling shaper_kick
> > >  o remove in_interrupt() tests.  from ->close we can always block, from
> > >    ->hard_start_xmit and timer context never
> > 
> > Do you really want to use a semaphore for a lock taken
> > %99 of the time in software IRQ context, which obviously
> > cannot sleep?
> 
> I want to change as little as possible from the previous variant ;-)

Fair enough, patch applied.  If this driver breaks as a result of
these changes, you get to keep the pieces ok? :-)
