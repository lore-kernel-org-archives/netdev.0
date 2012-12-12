From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: avoid requeues if possible
Date: Wed, 12 Dec 2012 00:24:17 -0500 (EST)
Message-ID: <20121212.002417.627468432851800439.davem@davemloft.net>
References: <1355277273.27891.166.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
	john.r.fastabend@intel.com
To: erdnetdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46498 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750855Ab2LLFYS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 00:24:18 -0500
In-Reply-To: <1355277273.27891.166.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <erdnetdev@gmail.com>
Date: Tue, 11 Dec 2012 17:54:33 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> With BQL being deployed, we can more likely have following behavior :
> 
> We dequeue a packet from qdisc in dequeue_skb(), then we realize target
> tx queue is in XOFF state in sch_direct_xmit(), and we have to hold the
> skb into gso_skb for later.
> 
> This shows in stats (tc -s qdisc dev eth0) as requeues.
> 
> Problem of these requeues is that high priority packets can not be
> dequeued as long as this (possibly low prio and big TSO packet) is not
> removed from gso_skb.
> 
> At 1Gbps speed, a full size TSO packet is 500 us of extra latency.
> 
> In some cases, we know that all packets dequeued from a qdisc are
> for a particular and known txq :
> 
> - If device is non multi queue
> - For all MQ/MQPRIO slave qdiscs
> 
> This patch introduces a new qdisc flag, TCQ_F_ONETXQUEUE to mark
> this capability, so that dequeue_skb() is allowed to dequeue a packet
> only if the associated txq is not stopped.
> 
> This indeed reduce latencies for high prio packets (or improve fairness
> with sfq/fq_codel), and almost remove qdisc 'requeues'.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
