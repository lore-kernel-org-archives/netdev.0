From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take19 1/4] kevent: Core files.
Date: Thu, 5 Oct 2006 18:15:56 +0400
Message-ID: <20061005141556.GA30715@2ka.mipt.ru>
References: <11587449471424@2ka.mipt.ru> <200610051156.25036.dada1@cosmosbay.com> <20061005102106.GE1015@2ka.mipt.ru> <200610051601.20701.hhh@imada.sdu.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:17604 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751236AbWJEOVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 10:21:37 -0400
To: Hans Henrik Happe <hhh@imada.sdu.dk>
Content-Disposition: inline
In-Reply-To: <200610051601.20701.hhh@imada.sdu.dk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 05, 2006 at 04:01:19PM +0200, Hans Henrik Happe (hhh@imada.sdu.dk) wrote:
> > And what happens when there are 3 empty at the beginning and \we need to
> > put there 4 ready events?
> 
> Couldn't there be 3 areas in the mmap buffer:
> 
> - Unused: entries that the kernel can alloc from.
> - Alloced: entries alloced by kernel but not yet used by user. Kernel can 
> update these if new events requires that.
> - Consumed: entries that the user are processing.
> 
> The user takes a set of alloced entries and make them consumed. Then it 
> processes the events after which it makes them unused. 
> 
> If there are no unused entries and the kernel needs some, it has wait for free 
> entries. The user has to notify when unused entries becomes available. It 
> could set a flag in the mmap'ed area to avoid unnessesary wakeups.
> 
> The are some details with indexing and wakeup notification that I have left 
> out, but I hope my idea is clear. I could give a more detailed description if 
> requested. Also, I'm a user-level programmer so I might not get the whole 
> picture.

This looks good on a picture, but how can you put it into page-based
storage without major and complex shared structures, which should be
properly locked between kernelspace and userspace?

> Hans Henrik Happe

-- 
	Evgeniy Polyakov
