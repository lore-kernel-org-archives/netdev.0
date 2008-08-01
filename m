From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Fri, 1 Aug 2008 07:41:32 +0000
Message-ID: <20080801074132.GA5158@ff.dom.local>
References: <20080731.052932.110299354.davem@davemloft.net> <20080801064810.GA4435@ff.dom.local> <20080801070150.GB4435@ff.dom.local> <20080801.000146.246099981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@axxeo.de, peterz@infradead.org,
	Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, mingo@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.178]:15219 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752758AbYHAHgP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 03:36:15 -0400
Received: by ik-out-1112.google.com with SMTP id c28so946718ika.5
        for <netdev@vger.kernel.org>; Fri, 01 Aug 2008 00:36:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080801.000146.246099981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 01, 2008 at 12:01:46AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Fri, 1 Aug 2008 07:01:50 +0000
> 
> > On Fri, Aug 01, 2008 at 06:48:10AM +0000, Jarek Poplawski wrote:
> > > On Thu, Jul 31, 2008 at 05:29:32AM -0700, David Miller wrote:
> > ...
> > > > diff --git a/net/core/dev.c b/net/core/dev.c
> > > > index 63d6bcd..69320a5 100644
> > > > --- a/net/core/dev.c
> > > > +++ b/net/core/dev.c
> > > > @@ -4200,6 +4200,7 @@ static void netdev_init_queues(struct net_device *dev)
> > > >  {
> > > >  	netdev_init_one_queue(dev, &dev->rx_queue, NULL);
> > > >  	netdev_for_each_tx_queue(dev, netdev_init_one_queue, NULL);
> > > > +	spin_lock_init(&dev->tx_global_lock);
> > > 
> > > This will probably need some lockdep annotations similar to
> > > _xmit_lock.
> > 
> > ...BTW, we probably could also consider some optimization here: the
> > xmit_lock of the first queue could be treated as special, and only
> > the owner could do such a freezing. This would save changes of
> > functionality to non mq devices. On the other hand, it would need
> > remembering about this special treatment (so, eg. a separate lockdep
> > initialization than all the others).
> 
> I think special casing the zero's queue's lock is a bad idea.
> Having a real top-level synchronizer is a powerful tool and
> we could use it for other things.

Sure, if there is really no problem with lockdep here, there is no
need for this at all.

Thanks for the explanations,
Jarek P.
