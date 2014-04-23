From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: avoid retransmits of TCP packets hanging
 in host queues
Date: Tue, 22 Apr 2014 21:28:25 -0400 (EDT)
Message-ID: <20140422.212825.238523997379918414.davem@davemloft.net>
References: <1397865790.19600.10.camel@edumazet-glaptop2.roam.corp.google.com>
	<1398041897.19600.26.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbaDWB20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 21:28:26 -0400
In-Reply-To: <1398041897.19600.26.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 20 Apr 2014 17:58:17 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit 0e280af026a5 ("tcp: introduce TCPSpuriousRtxHostQueues SNMP
> counter") we added a logic to detect when a packet was retransmitted
> while the prior clone was still in a qdisc or driver queue.
> 
> We are now confident we can do better, and catch the problem before
> we fragment a TSO packet before retransmit, or in TLP path.
> 
> This patch fully exploits the logic by simply canceling the spurious
> retransmit.
> Original packet is in a queue and will eventually leave the host.
> 
> This helps to avoid network collapses when some events make the RTO
> estimations very wrong, particularly when dealing with huge number of
> sockets with synchronized blast.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Great idea, looks good, applied.
