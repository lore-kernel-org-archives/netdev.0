From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take12 3/3] kevent: Timer notifications.
Date: Tue, 22 Aug 2006 09:48:55 +0400
Message-ID: <20060822054855.GA20517@2ka.mipt.ru>
References: <11561555893621@2ka.mipt.ru> <1156155589287@2ka.mipt.ru> <20060821111239.GA30945@infradead.org> <20060821120934.GA13399@2ka.mipt.ru> <20060821213650.dee2a0a3.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Christoph Hellwig <hch@infradead.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>, tglx@linutronix.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750774AbWHVFtf@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060821213650.dee2a0a3.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 21, 2006 at 09:36:50PM -0700, Andrew Morton (akpm@osdl.org) wrote:
> On Mon, 21 Aug 2006 16:09:34 +0400
> Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> 
> > On Mon, Aug 21, 2006 at 12:12:39PM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> > > > +static int __init kevent_init_timer(void)
> > > > +{
> > > > +	struct kevent_callbacks tc = {
> > > > +		.callback = &kevent_timer_callback, 
> > > > +		.enqueue = &kevent_timer_enqueue, 
> > > > +		.dequeue = &kevent_timer_dequeue};
> > > 
> > > I think this should be static, and the normal style to write it would be:
> > > 
> > > static struct kevent_callbacks tc = {
> > > 	.callback	= kevent_timer_callback,
> > > 	.enqueue	= kevent_timer_enqueue,
> > > 	.dequeue	= kevent_timer_dequeue,
> > > };
> > > 
> > > also please consider makring all the kevent_callbacks structs const
> > > to avoid false cacheline sharing and accidental modification, similar
> > > to what we did to various other operation vectors.
> > 
> > Actually I do not think it should be static, since it is only used for
> > initialization and it's members are copied into main structure.
> > 
> 
> It should be static __initdata a) so we don't need to construct it at
> runtime and b) so it gets dropped from memory after initcalls have run.
> 
> (But given that kevent_init_timer() also gets dropped from memory after initcalls
> it hardly matters).

That's what I'm talking about.

-- 
	Evgeniy Polyakov
