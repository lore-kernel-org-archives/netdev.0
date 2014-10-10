From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] macvlan: optimize receive path
Date: Fri, 10 Oct 2014 15:10:24 -0400 (EDT)
Message-ID: <20141010.151024.832041296782975325.davem@davemloft.net>
References: <cover.1412908929.git.jbaron@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, stephen@networkplumber.org,
	vyasevich@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: jbaron@akamai.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56129 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbaJJTK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2014 15:10:27 -0400
In-Reply-To: <cover.1412908929.git.jbaron@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jason Baron <jbaron@akamai.com>
Date: Fri, 10 Oct 2014 03:13:24 +0000 (GMT)

> So after porting this optimization to net-next, I found that the netperf
> results of TCP_RR regress right at the maximum peak of transactions/sec. That
> is as I increase the number of threads via the first argument to super_netperf,
> the number of transactions/sec keep increasing, peak, and then start
> decreasing. It is right at the peak, that I see a small regression with this
> patch (see results in patch 2/2).
> 
> Without the patch, the ksoftirqd threads are the top cpu consumers threads on
> the system, since the extra 'netif_rx()', is queuing more softirq work, whereas
> with the patch, the ksoftirqd threads are below all of the 'netserver' threads 
> in terms of their cpu usage. So there appears to be some interaction between how
> softirqs are serviced at the peak here and this patch. I think the test results
> are still supportive of this approach, but I wanted to be clear on my findings.

I think this is definitely the right thing to do, applied, thanks!
