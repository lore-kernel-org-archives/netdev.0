From: Andrew Morton <akpm@osdl.org>
Subject: Re: [take24 0/6] kevent: Generic event handling mechanism.
Date: Mon, 20 Nov 2006 01:15:16 -0800
Message-ID: <20061120011516.56311f7a.akpm@osdl.org>
References: <11630606361046@2ka.mipt.ru>
	<45564EA5.6020607@redhat.com>
	<20061113105458.GA8182@2ka.mipt.ru>
	<4560F07B.10608@redhat.com>
	<20061120082500.GA25467@2ka.mipt.ru>
	<20061120004301.d1815a95.akpm@osdl.org>
	<20061120085158.GA2816@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ulrich Drepper <drepper@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Alexander Viro <aviro@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:11453 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S933462AbWKTJRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Nov 2006 04:17:52 -0500
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061120085158.GA2816@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Nov 2006 11:51:59 +0300
Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:

> On Mon, Nov 20, 2006 at 12:43:01AM -0800, Andrew Morton (akpm@osdl.org) wrote:
> > > > >If thread calls kevent_wait() it means it has processed previous entries, 
> > > > >one can call kevent_wait() with $num parameter as zero, which
> > > > >means that thread does not want any new events, so nothing will be
> > > > >copied.
> > > > 
> > > > This doesn't solve the problem.  You could only request new events when 
> > > > all previously reported events are processed.  Plus: how do you report 
> > > > events if the you don't allow get_event pass them on?
> > > 
> > > Userspace should itself maintain order and possibility to get event in
> > > this implementation, kernel just returns events which were requested.
> > 
> > That would mean that in a multithreaded application (or multi-processes
> > sharing the same MAP_SHARED ringbuffer), all threads/processes will be
> > slowed down to wait for the slowest one.
> 
> Not at all - all other threads can call kevent_get_events() with theirs
> own place in the ring buffer, so while one of them is processing an
> entry, others can fill next entries.

eh?  That's not a ringbuffer, and it sounds awfully complex.

I don't know if this (new?) proposal resolves the
events-gets-lost-due-to-thread-cancellation problem?  Would need to see
considerably more detail.

