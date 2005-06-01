From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH] shaper.c: fix locking
Date: Wed, 1 Jun 2005 07:21:50 +0200
Message-ID: <20050601052149.GA11935@lst.de>
References: <20050527115450.GA19469@lst.de> <20050531.144114.78710204.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050531.144114.78710204.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 31, 2005 at 02:41:14PM -0700, David S. Miller wrote:
> From: Christoph Hellwig <hch@lst.de>
> Subject: [PATCH] shaper.c: fix locking
> Date: Fri, 27 May 2005 13:54:50 +0200
> 
> >  o use a semaphore instead of an opencoded and racy lock
> >  o move locking out of shaper_kick and into the callers - most just
> >    released the lock before calling shaper_kick
> >  o remove in_interrupt() tests.  from ->close we can always block, from
> >    ->hard_start_xmit and timer context never
> 
> Do you really want to use a semaphore for a lock taken
> %99 of the time in software IRQ context, which obviously
> cannot sleep?

I want to change as little as possible from the previous variant ;-)
