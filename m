From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: use an RB tree for ooo receive queue
Date: Thu, 08 Sep 2016 17:26:33 -0700 (PDT)
Message-ID: <20160908.172633.443737423657557877.davem@davemloft.net>
References: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wygivan@google.com, ycheng@google.com,
        ncardwell@google.com, ilpo.jarvinen@helsinki.fi
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42948 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbcIIA1K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:27:10 -0400
In-Reply-To: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Sep 2016 14:49:28 -0700

> From: Yaogong Wang <wygivan@google.com>
> 
> Over the years, TCP BDP has increased by several orders of magnitude,
> and some people are considering to reach the 2 Gbytes limit.
> 
> Even with current window scale limit of 14, ~1 Gbytes maps to ~740,000
> MSS.
>     
> In presence of packet losses (or reorders), TCP stores incoming packets
> into an out of order queue, and number of skbs sitting there waiting for
> the missing packets to be received can be in the 10^5 range.
> 
> Most packets are appended to the tail of this queue, and when
> packets can finally be transferred to receive queue, we scan the queue
> from its head.
> 
> However, in presence of heavy losses, we might have to find an arbitrary
> point in this queue, involving a linear scan for every incoming packet,
> throwing away cpu caches.
> 
> This patch converts it to a RB tree, to get bounded latencies.
> 
> Yaogong wrote a preliminary patch about 2 years ago.
> Eric did the rebase, added ofo_last_skb cache, polishing and tests.
> 
> Tested with network dropping between 1 and 10 % packets, with good
> success (about 30 % increase of throughput in stress tests)
> 
> Next step would be to also use an RB tree for the write queue at sender
> side ;)
> 
> Signed-off-by: Yaogong Wang <wygivan@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

The sooner this gets applied the sooner it gets tested and any remaining
bugs discovered and fixed.

Applied, thanks Eric.
