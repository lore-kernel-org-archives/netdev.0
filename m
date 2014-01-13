From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: gro: change GRO overflow strategy
Date: Mon, 13 Jan 2014 11:46:27 -0800 (PST)
Message-ID: <20140113.114627.1398138098446476409.davem@davemloft.net>
References: <1389305539.31367.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, hkchu@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38165 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751659AbaAMTq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 14:46:28 -0500
In-Reply-To: <1389305539.31367.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 09 Jan 2014 14:12:19 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> GRO layer has a limit of 8 flows being held in GRO list,
> for performance reason.
> 
> When a packet comes for a flow not yet in the list,
> and list is full, we immediately give it to upper
> stacks, lowering aggregation performance.
> 
> With TSO auto sizing and FQ packet scheduler, this situation
> happens more often.
> 
> This patch changes strategy to simply evict the oldest flow of
> the list. This works better because of the nature of packet
> trains for which GRO is efficient. This also has the effect
> of lowering the GRO latency if many flows are competing.
> 
> Tested :
> 
> Used a 40Gbps NIC, with 4 RX queues, and 200 concurrent TCP_STREAM
> netperf.
> 
> Before patch, aggregate rate is 11Gbps (while a single flow can reach
> 30Gbps)
> 
> After patch, line rate is reached.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, looks great.

If someone is really concerned about improving the list traversal,
we can maintain a tail pointer.
