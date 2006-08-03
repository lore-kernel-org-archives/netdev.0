From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take3 4/4] kevent: poll/select() notifications. Timer notifications.
Date: Thu, 3 Aug 2006 13:48:12 +0400
Message-ID: <20060803094812.GA29798@2ka.mipt.ru>
References: <11545983601@2ka.mipt.ru> <200608031143.03064.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932459AbWHCJtJ@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <200608031143.03064.dada1@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 03, 2006 at 11:43:02AM +0200, Eric Dumazet (dada1@cosmosbay.com) wrote:
> On Thursday 03 August 2006 11:46, Evgeniy Polyakov wrote:
> > poll/select() notifications. Timer notifications.
> >
> > +++ b/kernel/kevent/kevent_poll.c
> 
> > +static int kevent_poll_wait_callback(wait_queue_t *wait,
> > +		unsigned mode, int sync, void *key)
> > +{
> > +	struct kevent_poll_wait_container *cont =
> > +		container_of(wait, struct kevent_poll_wait_container, wait);
> > +	struct kevent *k = cont->k;
> > +	struct file *file = k->st->origin;
> > +	unsigned long flags;
> > +	u32 revents, event;
> > +
> > +	revents = file->f_op->poll(file, NULL);
> > +	spin_lock_irqsave(&k->ulock, flags);
> > +	event = k->event.event;
> > +	spin_unlock_irqrestore(&k->ulock, flags);
> 
> Not sure why you take a spinlock just to read a u32

You are right, it is not needed there.
Thank you.

> Eric

-- 
	Evgeniy Polyakov
