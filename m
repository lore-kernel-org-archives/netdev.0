From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] softirq: reduce latencies
Date: Fri, 04 Jan 2013 13:49:10 -0800 (PST)
Message-ID: <20130104.134910.1157297903826332014.davem@davemloft.net>
References: <1357250880.2685.29.camel@bwh-desktop.uk.solarflarecom.com>
	<1357252816.21409.26384.camel@edumazet-glaptop>
	<1357285780.21409.28416.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41122 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755254Ab3ADVtL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 16:49:11 -0500
In-Reply-To: <1357285780.21409.28416.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Jan 2013 23:49:40 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In various network workloads, __do_softirq() latencies can be up
> to 20 ms if HZ=1000, and 200 ms if HZ=100.
> 
> This is because we iterate 10 times in the softirq dispatcher,
> and some actions can consume a lot of cycles.
> 
> This patch changes the fallback to ksoftirqd condition to :
> 
> - A time limit of 2 ms.
> - need_resched() being set on current task
> 
> When one of this condition is met, we wakeup ksoftirqd for further
> softirq processing if we still have pending softirqs.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: David S. Miller <davem@davemloft.net>
