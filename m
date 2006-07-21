From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Fri, 21 Jul 2006 11:26:41 +0400
Message-ID: <20060721072641.GE5151@2ka.mipt.ru>
References: <20060719131915.GA21942@ms2.inr.ac.ru> <20060720073223.GA15567@tservice.net.ru> <20060720164100.GA9213@ms2.inr.ac.ru> <20060720210849.GA28715@tservice.net.ru> <5640c7e00607201440v38911f9ble6dbee9f6725be99@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:32659 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161006AbWGUH05 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jul 2006 03:26:57 -0400
To: Ian McDonald <ian.mcdonald@jandi.co.nz>
Content-Disposition: inline
In-Reply-To: <5640c7e00607201440v38911f9ble6dbee9f6725be99@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 21, 2006 at 09:40:32AM +1200, Ian McDonald (ian.mcdonald@jandi.co.nz) wrote:
> >If we consider netchannels as how Van Jackobson discribed them, then
> >mutext is not needed, since it is impossible to have several readers or
> >writers. But in socket case even if there is only one userspace
> >consumer, that lock must be held to protect against bh (or introduce
> >several queues and complicate a lot their's management (ucopy for
> >example)).
> >
> As I recall Van's talk you don't need a lock with a ring buffer if you
> have a start and end variable pointing to location within ring buffer.
> 
> He didn't explain this in great depth as it is computer science 101
> but here is how I would explain it:
> 
> Once socket is initialiased consumer is the only one that sets start
> variable and network driver reads this only. It is the other way
> around for the end variable. As long as the writes are atomic then you
> are fine. You only need one ring buffer in this scenario and two
> atomic variables.
> 
> Having atomic writes does have overhead but far less than locking semantic.

With netchannels and one data producer it should not be even atomic.
Problems start to appear when there are several producers or consumers -
there must be implemented either atomic or locking logic indeed.

> -- 
> Ian McDonald
> Web: http://wand.net.nz/~iam4
> Blog: http://imcdnzl.blogspot.com
> WAND Network Research Group
> Department of Computer Science
> University of Waikato
> New Zealand

-- 
	Evgeniy Polyakov
