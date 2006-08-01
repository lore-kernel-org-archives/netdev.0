From: James Morris <jmorris@namei.org>
Subject: Re: [take2 1/4] kevent: core files.
Date: Tue, 1 Aug 2006 10:27:36 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608011024380.11168@d.namei>
References: <11544248451203@2ka.mipt.ru> <Pine.LNX.4.64.0608010945090.10827@d.namei>
 <20060801135538.GA356@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751628AbWHAO1l@vger.kernel.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060801135538.GA356@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Aug 2006, Evgeniy Polyakov wrote:

> On Tue, Aug 01, 2006 at 09:46:58AM -0400, James Morris (jmorris@namei.org) wrote:
> > On Tue, 1 Aug 2006, Evgeniy Polyakov wrote:
> > 
> > > +	u->ready_num = 0;
> > > +#ifdef CONFIG_KEVENT_USER_STAT
> > > +	u->wait_num = u->im_num = u->total = 0;
> > > +#endif
> > 
> > Generally, #ifdefs in the body of the kernel code are discouraged.  Can 
> > you abstract these out as static inlines?
> 
> Yes, it is possible.
> I would ask is it needed at all?

Yes, please, it is standard kernel development practice.

Otherwise, the kernel will turn into an unmaintainable #ifdef jungle.

> It contains number of immediately fired
> events (i.e. those which were ready when event was added and thus
> syscall returned immediately showing that it is ready), total number of
> events, which were inserted in the given queue and number of events
> which were marked as ready after they were inserted.
> Currently it is compilation option which ends up in printk with above
> info when kevent queue is removed.

Fine, make 

static inline void kevent_user_stat_reset(u);

etc.

which compile to nothing when it's not confifgured.


-- 
James Morris
<jmorris@namei.org>
