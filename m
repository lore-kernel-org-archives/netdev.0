From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take12 3/3] kevent: Timer notifications.
Date: Mon, 21 Aug 2006 21:36:50 -0700
Message-ID: <20060821213650.dee2a0a3.akpm@osdl.org>
References: <11561555893621@2ka.mipt.ru>
	<1156155589287@2ka.mipt.ru>
	<20060821111239.GA30945@infradead.org>
	<20060821120934.GA13399@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Christoph Hellwig <hch@infradead.org>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>, tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64680 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751279AbWHVEhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2006 00:37:36 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060821120934.GA13399@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 Aug 2006 16:09:34 +0400
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Mon, Aug 21, 2006 at 12:12:39PM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> > > +static int __init kevent_init_timer(void)
> > > +{
> > > +	struct kevent_callbacks tc = {
> > > +		.callback = &kevent_timer_callback, 
> > > +		.enqueue = &kevent_timer_enqueue, 
> > > +		.dequeue = &kevent_timer_dequeue};
> > 
> > I think this should be static, and the normal style to write it would be:
> > 
> > static struct kevent_callbacks tc = {
> > 	.callback	= kevent_timer_callback,
> > 	.enqueue	= kevent_timer_enqueue,
> > 	.dequeue	= kevent_timer_dequeue,
> > };
> > 
> > also please consider makring all the kevent_callbacks structs const
> > to avoid false cacheline sharing and accidental modification, similar
> > to what we did to various other operation vectors.
> 
> Actually I do not think it should be static, since it is only used for
> initialization and it's members are copied into main structure.
> 

It should be static __initdata a) so we don't need to construct it at
runtime and b) so it gets dropped from memory after initcalls have run.

(But given that kevent_init_timer() also gets dropped from memory after initcalls
it hardly matters).
