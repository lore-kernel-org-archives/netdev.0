From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take2 1/4] kevent: core files.
Date: Tue, 1 Aug 2006 17:55:38 +0400
Message-ID: <20060801135538.GA356@2ka.mipt.ru>
References: <11544248451203@2ka.mipt.ru> <Pine.LNX.4.64.0608010945090.10827@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:17602 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751308AbWHAN4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 09:56:04 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0608010945090.10827@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2006 at 09:46:58AM -0400, James Morris (jmorris@namei.org) wrote:
> On Tue, 1 Aug 2006, Evgeniy Polyakov wrote:
> 
> > +	u->ready_num = 0;
> > +#ifdef CONFIG_KEVENT_USER_STAT
> > +	u->wait_num = u->im_num = u->total = 0;
> > +#endif
> 
> Generally, #ifdefs in the body of the kernel code are discouraged.  Can 
> you abstract these out as static inlines?

Yes, it is possible.
I would ask is it needed at all? It contains number of immediately fired
events (i.e. those which were ready when event was added and thus
syscall returned immediately showing that it is ready), total number of
events, which were inserted in the given queue and number of events
which were marked as ready after they were inserted.
Currently it is compilation option which ends up in printk with above
info when kevent queue is removed.
 
> - James
> -- 
> James Morris
> <jmorris@namei.org>

-- 
	Evgeniy Polyakov
