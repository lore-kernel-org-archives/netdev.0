From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/4] kevent: core files.
Date: Sat, 24 Jun 2006 01:43:34 +0400
Message-ID: <20060623214334.GA25799@2ka.mipt.ru>
References: <20060622171436.GA26161@2ka.mipt.ru> <20060623070933.GA20291@2ka.mipt.ru> <20060623184457.GA13617@kvack.org> <20060623192422.GA11508@2ka.mipt.ru> <20060623195513.GC14126@kvack.org> <20060623201716.GA26168@2ka.mipt.ru> <20060623204442.GE14126@kvack.org> <20060623210826.GC26168@2ka.mipt.ru> <20060623213144.GF14126@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:38060 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1752097AbWFWVnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 17:43:33 -0400
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20060623213144.GF14126@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 05:31:44PM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> On Sat, Jun 24, 2006 at 01:08:27AM +0400, Evgeniy Polyakov wrote:
> > On Fri, Jun 23, 2006 at 04:44:42PM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> > > > AIO completion approach was designed to be used with process context VFS
> > > > update. read/write approach can not cover other types of notifications,
> > > > like inode updates or timers.
> > > 
> > > The completion event is 100% generic and does not need to come from process 
> > > context.  Calling aio_complete() from irq context is entirely valid.
> > 
> > put_ioctx() can sleep.
> 
> Err, no, that should definately not be the case.  If it can, someone has 
> completely broken aio.

When reference counter hits zero it flushes aio workqueue, which can
sleep.
put_ioctx() -> __put_ioctx() -> cancel_delayed_work()/flush_workqueue().

It is there at least from 2.6.15 days (it is the oldest tree I can
access using my extremely slow GPRS link).

Hang the looter!

> 		-ben

-- 
	Evgeniy Polyakov
