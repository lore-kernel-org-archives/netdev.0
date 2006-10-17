From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take19 1/4] kevent: Core files.
Date: Tue, 17 Oct 2006 14:42:43 +0400
Message-ID: <20061017104242.GB19246@2ka.mipt.ru>
References: <11587449471424@2ka.mipt.ru> <4532C2C5.6080908@redhat.com> <453465B6.1000401@densedata.com> <200610170100.10500.chase.venters@clientec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Johann Borck <johann.borck@densedata.com>,
	Ulrich Drepper <drepper@redhat.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Ulrich Drepper <drepper@gmail.com>,
	lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:5014 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161216AbWJQKn2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 06:43:28 -0400
To: Chase Venters <chase.venters@clientec.com>
Content-Disposition: inline
In-Reply-To: <200610170100.10500.chase.venters@clientec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2006 at 12:59:47AM -0500, Chase Venters (chase.venters@clientec.com) wrote:
> On Tuesday 17 October 2006 00:09, Johann Borck wrote:
> > Regarding mukevent I'm thinking of a event-type specific struct, that is
> > filled by the originating code, and placed into a per-event-type ring
> > buffer (which  requires modification of kevent_wait).
> 
> I'd personally worry about an implementation that used a per-event-type ring 
> buffer, because you're still left having to hack around starvation issues in 
> user-space. It is of course possible under the current model for anyone who 
> wants per-event-type ring buffers to have them - just make separate kevent 
> sets.
> 
> I haven't thought this through all the way yet, but why not have variable 
> length event structures and have the kernel fill in a "next" pointer in each 
> one? This could even be used to keep backwards binary compatibility while 

Why do we want variable size structures in mmap ring buffer?

> adding additional fields to the structures over time, though no space would 
> be wasted on modern programs. You still end up with a question of what to do 
> in case of overflow, but I'm thinking the thing to do in that case might be 
> to start pushing overflow events onto a linked list which can be written back 
> into the ring buffer when space becomes available. The appropriate behavior 
> would be to throw new events on the linked list if the linked list had any 
> events, so that things are delivered in order, but write to the mapped buffer 
> directly otherwise.

I think in a similar way.
Kevent actually do not require such list, since it has already queue of
the ready events.

-- 
	Evgeniy Polyakov
