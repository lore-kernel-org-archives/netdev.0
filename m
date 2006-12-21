From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take28-resend_1->0 0/8] kevent: Generic event handling mechanism.
Date: Thu, 21 Dec 2006 13:35:39 +0300
Message-ID: <20061221103539.GA4099@2ka.mipt.ru>
References: <3154985aa0591036@2ka.mipt.ru> <11666924573643@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>,
	Christoph Hellwig <hch@infradead.org>,
	Chase Venters <chase.venters@clientec.com>,
	Johann Borck <johann.borck@densedata.com>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:35832 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965202AbWLUKhl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Dec 2006 05:37:41 -0500
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <11666924573643@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 21, 2006 at 12:14:17PM +0300, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> 
> Generic event handling mechanism.
> 
> Kevent is a generic subsytem which allows to handle event notifications.
> It supports both level and edge triggered events. It is similar to
> poll/epoll in some cases, but it is more scalable, it is faster and
> allows to work with essentially eny kind of events.
> 
> Events are provided into kernel through control syscall and can be read
> back through ring buffer or using usual syscalls.
> Kevent update (i.e. readiness switching) happens directly from internals
> of the appropriate state machine of the underlying subsytem (like
> network, filesystem, timer or any other).
> 
> Homepage:
> http://tservice.net.ru/~s0mbre/old/?section=projects&item=kevent
> 
> Documentation page:
> http://linux-net.osdl.org/index.php/Kevent
> 
> Consider for inclusion.

Due to this stall kevent inclusion into lighttpd CVS tree is postponed.

The last version will be released saturday or sunday, and looking into
overhelming flow of feedback comments on this feature, project will not
be released to linux-kernel@, after this I will
complete netchannels support and start kevent based AIO project - mostly
network AIO with new design, which is based on set of entities, which
can describe set of tasks which should be performed
asynchronously (from user point of view, although read and write
obviously must be done after open and before close), for example syscall
which gets as parameter destination socket and local filename (with
optional offset and length fields), which will asynchronously from user
point of view open a file and transfer requested part to the destination
socket and then return opened file descriptor (or it can be closed if
requested). Similar mechanism can be done for read/write calls.

Interested parties will be able to apply patches for theirs own kernels.

-- 
	Evgeniy Polyakov
