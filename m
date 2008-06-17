From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: Re: Killing sk->sk_callback_lock
Date: Tue, 17 Jun 2008 16:15:46 -0600
Message-ID: <4857FF69.456F.00C7.0@novell.com>
References: <4856C12F020000C700039679@lucius.provo.novell.com>
 <20080616.185328.85842051.davem@davemloft.net>
 <4857862A.456F.00C7.0@novell.com>
 <20080617.144041.38758483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <herbert@gondor.apana.org.au>,
	"Gregory Haskins" <GHaskins.WAL-1.WALTHAM@novell.com>,
	<chuck.lever@oracle.com>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucius.provo.novell.com ([137.65.248.127]:10121 "EHLO
	lucius.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756114AbYFQWPv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 18:15:51 -0400
In-Reply-To: <20080617.144041.38758483.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>>> On Tue, Jun 17, 2008 at  5:40 PM, in message
<20080617.144041.38758483.davem@davemloft.net>, David Miller
<davem@davemloft.net> wrote: 
> From: "Patrick Mullaney" <pmullaney@novell.com>
> Date: Tue, 17 Jun 2008 07:38:29 -0600
> 
>> >>> On Mon, Jun 16, 2008 at  9:53 PM, in message
>> <20080616.185328.85842051.davem@davemloft.net>, David Miller
>> <davem@davemloft.net> wrote: 
>> > Once the task is woken up the first time, future calls to
>> > these callback functions should do nothing other than take
>> > the sk_callback_lock and test some state.
>> > 
>> > Since the task is awake already, wakeups should be bypassed
>> > or at worst be a nop.
>> 
>> The task can go directly back into a wait. This will effectively yield 2
>> wake ups per udp request-response.
> 
> I made the mistake of assuming that a high performance threaded
> networking application would use non-blocking operations and
> select/poll/epoll, which is clearly not the case here.
> 
This is the standard netperf udp request response benchmark - it measures
back to back send/recv and is not necessarily high performance (async).

> It's blocking in a recv() and this is woken up by a write space
> extraneous wakeup.
> 
> It does need to be fixed and I'll look at the most recent patch
> submission and also try to imagine some other ideas.  Herbert
> mentioned creating a seperate wait queue for write space wakeups.

Yeah, I think I mentioned that approach in my first email about this. It
seemed like it would require adding to the socket struct so I decided to
try to do it without touching that. I am not positive but changing the odd
behavior of the SOCK_NOSPACE flag(mentioned in previous email) seems like
it may be in order regardless of the approach to the extra wake up.

