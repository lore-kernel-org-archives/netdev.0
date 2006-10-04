From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take19 1/4] kevent: Core files.
Date: Wed, 4 Oct 2006 10:48:55 +0400
Message-ID: <20061004064855.GA1981@2ka.mipt.ru>
References: <11587449471424@2ka.mipt.ru> <1158744950130@2ka.mipt.ru> <a36005b50610032334n50e66198rdfef30e4ccf545c8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:22967 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1030399AbWJDGt2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 02:49:28 -0400
To: Ulrich Drepper <drepper@gmail.com>
Content-Disposition: inline
In-Reply-To: <a36005b50610032334n50e66198rdfef30e4ccf545c8@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 03, 2006 at 11:34:02PM -0700, Ulrich Drepper (drepper@gmail.com) wrote:
> On 9/20/06, Evgeniy Polyakov <johnpol@2ka.mipt.ru> wrote:
> >This patch includes core kevent files:
> >[...]
> 
> I tried to look at the example programs before and failed.  I tried
> again.  Where can I find up-to-date example code?

http://tservice.net.ru/~s0mbre/archive/kevent/evserver_kevent.c
http://tservice.net.ru/~s0mbre/archive/kevent/evtest.c

Structures were not changed from the beginning of kevent project.

> Some other points:
> 
> - I really would prefer not to rush all this into the upstream kernel.
> The main problem is that the ring buffer interface is a shared data
> structure.  These are always tricky.  We need to find the right
> combination between size (as small as possible) and supporting all the
> interfaces.

mmap interface itself is in question, since it allows to create dos
since there are no rlimits for pinned memory.

> - so far only the timer and aio notification is speced out.  What
> about the rest?  Are we sure all aspects can be expressed?  I am not
> yet.

AIO was removed from patchset by request of Cristoph.
Timers, network AIO, fs AIO, socket nortifications and poll/select
events work well with existing structures.

> - we need an interface to add an event from userlevel.  I.e., we need
> to be able to synthesize events.  There are events (like, for instance
> the async DNS functionality) which come from userlevel code.
> 
> I would very much prefer we look at the other events before setting
> the data structures in stone.

Signals and userspace events (hello solaris) easily fits into existing
structures.

It is even possible to create variable sized kevents - each kevent
contain pointer to user's data, which can be considered as pointer to
additional area (it's size kernel implementation for given kevent type
can determine from other parameters or use predefined one and fetch
additional data in ->enqueue() callback).

-- 
	Evgeniy Polyakov
