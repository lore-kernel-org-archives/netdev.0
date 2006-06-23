From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/4] kevent: core files.
Date: Fri, 23 Jun 2006 23:24:29 +0400
Message-ID: <20060623192422.GA11508@2ka.mipt.ru>
References: <20060622171436.GA26161@2ka.mipt.ru> <20060623070933.GA20291@2ka.mipt.ru> <20060623184457.GA13617@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:19841 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751951AbWFWTYa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 15:24:30 -0400
To: Benjamin LaHaise <bcrl@kvack.org>
Content-Disposition: inline
In-Reply-To: <20060623184457.GA13617@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 02:44:57PM -0400, Benjamin LaHaise (bcrl@kvack.org) wrote:
> On Fri, Jun 23, 2006 at 11:09:34AM +0400, Evgeniy Polyakov wrote:
> > This patch includes core kevent files:
> >  - userspace controlling
> >  - kernelspace interfaces
> >  - initialisation
> >  - notification state machines
> 
> We don't need yet another event mechanism in the kernel, so I don't see 
> why the new syscalls should be added when they don't interoperate with 
> existing solutions.  If your results are enough to sway akpm that it is 
> worth taking the patches, then it would make sense to merge the code with 
> the already in-tree APIs.

What API are you talking about?
There is only epoll(), which is 40% slower than kevent, and AIO, which
works not as state machine, but as repeated call for the same work.
There is also inotify, which allocates new message each time event
occurs, which is not a good solution for every situation.

Linux just does not have unified event processing mechanism, which was
pointed to many times in AIO mail list and when epoll() was only
introduced. I would even say, that Linux does not have such mechanism at
all, since every potential user implements it's own, which can not be
used with others.

Kevent fixes that. Although implementation itself can be suboptimal for
some cases or even unacceptible at all, but it is really needed
functionality.

Every existing notification can be built on top of kevent. One can find
how easy it was to implement generic poll/select notifications (what
epoll() does) or socket notifications (which are similar to epoll(), but
are called from inside socket state machine, thus improving processing
performance).

> 		-ben

-- 
	Evgeniy Polyakov
