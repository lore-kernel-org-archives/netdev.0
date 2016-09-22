From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: implement TSQ for retransmits
Date: Thu, 22 Sep 2016 02:44:54 -0400 (EDT)
Message-ID: <20160922.024454.403661058785255364.davem@davemloft.net>
References: <1474424880.23058.65.camel@edumazet-glaptop3.roam.corp.google.com>
        <1474436758.23058.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, ycheng@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55422 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755134AbcIVGo5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 02:44:57 -0400
In-Reply-To: <1474436758.23058.75.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 20 Sep 2016 22:45:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We saw sch_fq drops caused by the per flow limit of 100 packets and TCP
> when dealing with large cwnd and bursts of retransmits.
> 
> Even after increasing the limit to 1000, and even after commit
> 10d3be569243 ("tcp-tso: do not split TSO packets at retransmit time"),
> we can still have these drops.
> 
> Under certain conditions, TCP can spend a considerable amount of
> time queuing thousands of skbs in a single tcp_xmit_retransmit_queue()
> invocation, incurring latency spikes and stalls of other softirq
> handlers.
> 
> This patch implements TSQ for retransmits, limiting number of packets
> and giving more chance for scheduling packets in both ways.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>

Applied.
