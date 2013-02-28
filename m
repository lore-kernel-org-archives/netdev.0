From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: avoid wakeups for pure ACK
Date: Thu, 28 Feb 2013 15:38:07 -0500 (EST)
Message-ID: <20130228.153807.1427421999295174182.davem@davemloft.net>
References: <1361984703.11403.43.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, therbert@google.com,
	ycheng@google.com, ak@linux.intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175Ab3B1UiK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 15:38:10 -0500
In-Reply-To: <1361984703.11403.43.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Feb 2013 09:05:03 -0800

> TCP prequeue mechanism purpose is to let incoming packets
> being processed by the thread currently blocked in tcp_recvmsg(),
> instead of behalf of the softirq handler, to better adapt flow
> control on receiver host capacity to schedule the consumer.
> 
> But in typical request/answer workloads, we send request, then
> block to receive the answer. And before the actual answer, TCP
> stack receives the ACK packets acknowledging the request.
> 
> Processing pure ACK on behalf of the thread blocked in tcp_recvmsg()
> is a waste of resources, as thread has to immediately sleep again
> because it got no payload.
> 
> This patch avoids the extra context switches and scheduler overhead.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
