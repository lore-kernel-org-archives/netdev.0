From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net_sched: qdisc_alloc_handle() can be too
 slow
Date: Tue, 03 Jan 2012 13:03:53 -0500 (EST)
Message-ID: <20120103.130353.716810185692904362.davem@davemloft.net>
References: <1325584697.2320.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<1325584811.2320.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave.taht@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754180Ab2ACSD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 13:03:56 -0500
In-Reply-To: <1325584811.2320.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 03 Jan 2012 11:00:11 +0100

> When trying to allocate ~32768 qdiscs using autohandle mechanism, we can
> fill the space managed by kernel (handles in [8000-FFFF]:0000 range)
> 
> But O(N^2) qdisc_alloc_handle() loops 0x10000 times instead of 0x8000
> 
> time tc add qdisc add dev eth0 parent 10:7fff pfifo limit 10
> RTNETLINK answers: Cannot allocate memory
> real    1m54.826s
> user    0m0.000s
> sys     0m0.004s
> 
> INFO: rcu_sched_state detected stall on CPU 0 (t=60000 jiffies)
> 
> Half number of loops, and add a cond_resched() call.
> We hold rtnl at this point.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Dave Taht <dave.taht@gmail.com>

Applied, thanks Eric.  I always cringed when I looked at this function :)
