From: "Patrick Mullaney" <pmullaney@novell.com>
Subject: Re: Killing sk->sk_callback_lock
Date: Tue, 17 Jun 2008 07:38:29 -0600
Message-ID: <4857862A.456F.00C7.0@novell.com>
References: <484F43A3020000760003F543@lucius.provo.novell.com>
 <4856C12F020000C700039679@lucius.provo.novell.com>
 <20080616.185328.85842051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: <herbert@gondor.apana.org.au>,
	"Gregory Haskins" <GHaskins.WAL-1.WALTHAM@novell.com>,
	<chuck.lever@oracle.com>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lucius.provo.novell.com ([137.65.248.127]:39705 "EHLO
	lucius.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755388AbYFQNie convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jun 2008 09:38:34 -0400
In-Reply-To: <20080616.185328.85842051.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>>> On Mon, Jun 16, 2008 at  9:53 PM, in message
<20080616.185328.85842051.davem@davemloft.net>, David Miller
<davem@davemloft.net> wrote: 
> From: "Patrick Mullaney" <pmullaney@novell.com>
> Date: Mon, 16 Jun 2008 19:38:23 -0600
> 
>> The overhead I was trying to address was scheduler overhead.
> 
> Neither Herbert nor I are convinced of this yet, and you have
> to show us why you think this is the problem and not (in
> our opinion) the more likely sk_callback_lock overhead.

I think Greg has done an excellent job in describing what is
happening and how we found the issue so I won't go into
that unless you have further questions. We are both available
for an IRC chat on the problem if you would like. The only
thing I want to make clear is that lockstat is showing
sk_callback_lock as uncontended. I ran this once again just
to be sure last night(zero contentions). 

> 
> I am tiring of stating this over and over so please address
> this in any future correspondance.

I am confused by this statement - "over and over" implies more
than once. It seems to me that you stated this in one email
that you and Herbert came to this conclusion on IRC. What data
supports this conclusion? 

> 
> Once the task is woken up the first time, future calls to
> these callback functions should do nothing other than take
> the sk_callback_lock and test some state.
> 
> Since the task is awake already, wakeups should be bypassed
> or at worst be a nop.

The task can go directly back into a wait. This will effectively yield 2
wake ups per udp request-response.


