From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Mon, 27 Oct 2008 02:57:33 -0700 (PDT)
Message-ID: <20081027.025733.48914319.davem@davemloft.net>
References: <20081026100555.GA26033@ioremap.net>
	<20081026.193451.36032548.davem@davemloft.net>
	<20081027093035.GA23743@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zbr@ioremap.net, akpm@linux-foundation.org, a.p.zijlstra@chello.nl,
	efault@gmx.de, jkosina@suse.cz, rjw@sisk.pl,
	s0mbre@tservice.net.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751496AbYJ0J54 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 05:57:56 -0400
In-Reply-To: <20081027093035.GA23743@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Mon, 27 Oct 2008 10:30:35 +0100

> But it's a difficult call with no silver bullets. On one hand we have 
> folks putting more and more stuff into the context-switching hotpath on 
> the (mostly valid) point that the scheduler is a slowpath compared to 
> most other things.

This I heavily disagree with.  The scheduler should be so cheap
that you cannot possibly notice that it is even there for a benchmark
like tbench.

If we now think it's ok that picking which task to run is more
expensive than writing 64 bytes over a TCP socket and then blocking on
a read, I'd like to stop using Linux. :-) That's "real work" and if
the scheduler is more expensive than "real work" we lose.

I do want to remind you of a thread you participated in, in April,
where you complained about loopback TCP performance:

	http://marc.info/?l=linux-netdev&m=120696343707674&w=2

It might be fruitful for you to rerun your tests with CFS reverted
(start with 2.6.22 and progressively run your benchmark on every
release), you know, just for fun :-)

> On the other hand we've got folks doing high-context-switch ratio
> benchmarks and complaining about the overhead whenever something
> goes in that improves the quality of scheduling of a workload that
> does not context-switch as massively as tbench. It's a difficult
> balance and we cannot satisfy both camps.

We've always been proud of our scheduling overhead being extremely
low, and you have to face the simple fact that starting in 2.6.23 it's
been getting progressively more and more expensive.

Consistently so.

People even noticed it.
