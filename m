From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [take9 2/2] kevent: poll/select() notifications. Timer notifications.
Date: Wed, 16 Aug 2006 17:40:32 +0400
Message-ID: <20060816134032.GB4314@2ka.mipt.ru>
References: <1155536496588@2ka.mipt.ru> <11555364962857@2ka.mipt.ru> <20060816133014.GB32499@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: lkml <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Ulrich Drepper <drepper@redhat.com>,
	Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	Zach Brown <zach.brown@oracle.com>, tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:22496 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750824AbWHPNlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 09:41:17 -0400
To: Christoph Hellwig <hch@infradead.org>
Content-Disposition: inline
In-Reply-To: <20060816133014.GB32499@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 16, 2006 at 02:30:14PM +0100, Christoph Hellwig (hch@infradead.org) wrote:
> On Mon, Aug 14, 2006 at 10:21:36AM +0400, Evgeniy Polyakov wrote:
> > 
> > poll/select() notifications. Timer notifications.
> > 
> > This patch includes generic poll/select and timer notifications.
> > 
> > kevent_poll works simialr to epoll and has the same issues (callback
> > is invoked not from internal state machine of the caller, but through
> > process awake).
> 
> I'm not a big fan of duplicating code over and over.  kevent is a candidate
> for a generic event devlivery mechanisms which is a _very_ good thing.  But
> starting that system by duplicating existing functionality is not very nice.
> 
> What speaks against a patch the recplaces the epoll core by something that
> build on kevent while still supporting the epoll interface as a compatibility
> shim?

There is no problem from my side, but epoll and kevent_poll differs on
some aspects, so it can be better to not replace them for a while.

> > Timer notifications can be used for fine grained per-process time 
> > management, since interval timers are very inconvenient to use, 
> > and they are limited.
> 
> I have similar reservations about this one.  Having timers as part of a
> generic events system is very nice, but having so much duplicated functionality
> is not.  Cc'ed Thomas on behalf of the Timer cabal if there's a point in
> integrating this into a larger framework of timer code.
> 
> 
> Also it would be nice if you could submit each of the notifications as a patch
> on it's own.

Ok.

-- 
	Evgeniy Polyakov
