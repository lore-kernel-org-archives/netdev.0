From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/4] kevent: core files.
Date: Sat, 24 Jun 2006 01:08:27 +0400
Message-ID: <20060623210826.GC26168@2ka.mipt.ru>
References: <20060622171436.GA26161@2ka.mipt.ru> <20060623070933.GA20291@2ka.mipt.ru> <20060623184457.GA13617@kvack.org> <20060623192422.GA11508@2ka.mipt.ru> <20060623195513.GC14126@kvack.org> <20060623201716.GA26168@2ka.mipt.ru> <20060623204442.GE14126@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:43949 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1752060AbWFWVIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 17:08:43 -0400
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20060623204442.GE14126@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 04:44:42PM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> > AIO completion approach was designed to be used with process context VFS
> > update. read/write approach can not cover other types of notifications,
> > like inode updates or timers.
> 
> The completion event is 100% generic and does not need to come from process 
> context.  Calling aio_complete() from irq context is entirely valid.

put_ioctx() can sleep.
And the whole approach is different: AIO just wakes up requesting
thread, so user must provide a lot to be able to work with AIO.
It perfectly fits VFS design, but it is not acceptible for generic event
notifications.

> > Format of the structure transferred between the objects does not matter
> > at all. We can create a wrapper on kevent structures or kevent can
> > transform data from AIO objects.
> 
> > The main design goal of kevent is to provide easy connected hooks into
> > any state machine, which might be used by kernelspace to notify about
> > any kind of events without any knowledge of it's background nature.
> > Kevent can be used for example as notification blocks for address
> > changes or it can replace netlink completely (it can even emulate
> > event multicasting).
> > 
> > Kevent is queue of events, which can be transferred from any object to
> > any destination.
> 
> And io_getevents() reads a queue of events, so I'm not sure why you need 
> a new syscall.

It is not syscall, but overall design should be analyzed.
It is possible to use existing ssycalls, kevent design does not care
about how it's data structures are delivered to the internal
"processor".

> > Not at all!
> > Kevent is a mechanism, which allows to impleement AIO, network AIO, poll
> > and select, timer control, adaptive readhead (as example of AIO VFS
> > update). All the code I present shows how to use kevent, it is not part
> > of the kevent. One can find Makefile in kevent dir to check what is the
> > core of the subsystem, which allows to be used as a transport for
> > events.
> > 
> > AIO, NAIO, poll/select, socket and timer notifications are just users.
> > One can add it's own usage as easy as to call kevent_storage
> > initialization function and event generation function. All other pieces
> > are hidded in the implementation.
> 
> I'll look at adapting your code to use the existing syscalls.  Maybe code 
> will be better at expressing my concerns.

That would be great.

> 		-ben

-- 
	Evgeniy Polyakov
