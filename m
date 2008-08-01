From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
 __netif_schedule+0x2c/0x98()
Date: Fri, 01 Aug 2008 00:01:46 -0700 (PDT)
Message-ID: <20080801.000146.246099981.davem@davemloft.net>
References: <20080731.052932.110299354.davem@davemloft.net>
	<20080801064810.GA4435@ff.dom.local>
	<20080801070150.GB4435@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, netdev-BkyiQQGWkgE@public.gmane.org, peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
To: jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080801070150.GB4435-8HppEYmqbBCE+EvaaNYduQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 1 Aug 2008 07:01:50 +0000

> On Fri, Aug 01, 2008 at 06:48:10AM +0000, Jarek Poplawski wrote:
> > On Thu, Jul 31, 2008 at 05:29:32AM -0700, David Miller wrote:
> ...
> > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > index 63d6bcd..69320a5 100644
> > > --- a/net/core/dev.c
> > > +++ b/net/core/dev.c
> > > @@ -4200,6 +4200,7 @@ static void netdev_init_queues(struct net_device *dev)
> > >  {
> > >  	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
> > >  	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
> > > +	spin_lock_init(&dev->tx_global_lock);
> > 
> > This will probably need some lockdep annotations similar to
> > _xmit_lock.
> 
> ...BTW, we probably could also consider some optimization here: the
> xmit_lock of the first queue could be treated as special, and only
> the owner could do such a freezing. This would save changes of
> functionality to non mq devices. On the other hand, it would need
> remembering about this special treatment (so, eg. a separate lockdep
> initialization than all the others).

I think special casing the zero's queue's lock is a bad idea.
Having a real top-level synchronizer is a powerful tool and
we could use it for other things.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
