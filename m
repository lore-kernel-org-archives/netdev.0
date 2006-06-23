From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [1/4] kevent: core files.
Date: Fri, 23 Jun 2006 15:55:13 -0400
Message-ID: <20060623195513.GC14126@kvack.org>
References: <20060622171436.GA26161@2ka.mipt.ru> <20060623070933.GA20291@2ka.mipt.ru> <20060623184457.GA13617@kvack.org> <20060623192422.GA11508@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([66.96.29.28]:24238 "EHLO kanga.kvack.org")
	by vger.kernel.org with ESMTP id S1751981AbWFWTzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 15:55:19 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Content-Disposition: inline
In-Reply-To: <20060623192422.GA11508@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 23, 2006 at 11:24:29PM +0400, Evgeniy Polyakov wrote:
> What API are you talking about?
> There is only epoll(), which is 40% slower than kevent, and AIO, which
> works not as state machine, but as repeated call for the same work.
> There is also inotify, which allocates new message each time event
> occurs, which is not a good solution for every situation.

AIO can be implemented as a state machine.  Nothing in the API stops 
you from doing that, and in fact there was code which was implemented as 
a state machine used on 2.4 kernels.

> Linux just does not have unified event processing mechanism, which was
> pointed to many times in AIO mail list and when epoll() was only
> introduced. I would even say, that Linux does not have such mechanism at
> all, since every potential user implements it's own, which can not be
> used with others.

The epoll event API doesn't have space in the event fields for result codes 
as needed for AIO.  The AIO API does -- how is it lacking in this regard?

> Kevent fixes that. Although implementation itself can be suboptimal for
> some cases or even unacceptible at all, but it is really needed
> functionality.

At the expense of adding another API?  How is this a good thing?  Why 
not spit out events in the existing format?

> Every existing notification can be built on top of kevent. One can find
> how easy it was to implement generic poll/select notifications (what
> epoll() does) or socket notifications (which are similar to epoll(), but
> are called from inside socket state machine, thus improving processing
> performance).

So far your code is adding a lot without unifying anything.

		-ben
-- 
"Time is of no importance, Mr. President, only life is important."
Don't Email: <dont@kvack.org>.
