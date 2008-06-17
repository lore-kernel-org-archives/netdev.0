From: David Miller <davem@davemloft.net>
Subject: Re: Killing sk->sk_callback_lock
Date: Tue, 17 Jun 2008 14:40:41 -0700 (PDT)
Message-ID: <20080617.144041.38758483.davem@davemloft.net>
References: <4856C12F020000C700039679@lucius.provo.novell.com>
	<20080616.185328.85842051.davem@davemloft.net>
	<4857862A.456F.00C7.0@novell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, GHaskins.WAL-1.WALTHAM@novell.com,
	chuck.lever@oracle.com, netdev@vger.kernel.org
To: pmullaney@novell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48226
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757114AbYFQVkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 17:40:41 -0400
In-Reply-To: <4857862A.456F.00C7.0@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Patrick Mullaney" <pmullaney@novell.com>
Date: Tue, 17 Jun 2008 07:38:29 -0600

> >>> On Mon, Jun 16, 2008 at  9:53 PM, in message
> <20080616.185328.85842051.davem@davemloft.net>, David Miller
> <davem@davemloft.net> wrote: 
> > Once the task is woken up the first time, future calls to
> > these callback functions should do nothing other than take
> > the sk_callback_lock and test some state.
> > 
> > Since the task is awake already, wakeups should be bypassed
> > or at worst be a nop.
> 
> The task can go directly back into a wait. This will effectively yield 2
> wake ups per udp request-response.

I made the mistake of assuming that a high performance threaded
networking application would use non-blocking operations and
select/poll/epoll, which is clearly not the case here.

It's blocking in a recv() and this is woken up by a write space
extraneous wakeup.

It does need to be fixed and I'll look at the most recent patch
submission and also try to imagine some other ideas.  Herbert
mentioned creating a seperate wait queue for write space wakeups.
