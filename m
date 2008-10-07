From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 3/3] Convert the UDP hash lock to RCU
Date: Tue, 07 Oct 2008 10:31:30 +0200
Message-ID: <1223368290.26330.10.camel@lappy.programming.kicks-ass.net>
References: <20081006185026.GA10383@minyard.local>
	 <48EA8197.6080502@cosmosbay.com>
	 <20081006.144002.56418911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, minyard@acm.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59238 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751618AbYJGIbv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 04:31:51 -0400
In-Reply-To: <20081006.144002.56418911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-10-06 at 14:40 -0700, David Miller wrote:
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 06 Oct 2008 23:22:31 +0200
> 
> > Me wondering what impact this synchronize_rcu() can have on mono-threaded
> > VOIP applications using lot of UDP sockets. What is the maximum delay of
> > this function ?
> 
> The cost is enormous, we really can't use it here.
> 
> I have a patch that did top-level socket destruction using RCU,
> and that didn't use synchronize_rcu(), and that killed connection
> rates by up to %20.

Did you ever figure out why you lost those 20% ?

> I can only imagine what the cost would be if I had to add such a call
> in there.

Yeah, sync_rcu() is rediculously expensive, at best 3 jiffies IIRC.

