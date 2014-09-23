From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: add coalescing attempt in tcp_ofo_queue()
Date: Tue, 23 Sep 2014 12:48:29 -0400 (EDT)
Message-ID: <20140923.124829.1758543819770208914.davem@davemloft.net>
References: <1411140380.26859.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35561 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756101AbaIWQsa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Sep 2014 12:48:30 -0400
In-Reply-To: <1411140380.26859.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Sep 2014 08:26:20 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In order to make TCP more resilient in presence of reorders, we need
> to allow coalescing to happen when skbs from out of order queue are
> transferred into receive queue. LRO/GRO can be completely canceled
> in some pathological cases, like per packet load balancing on aggregated
> links.
> 
> I had to move tcp_try_coalesce() up in the file above tcp_ofo_queue()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> 
> Note: I am not sure we really need this part in tcp_try_coalesce(),
> as I doubt we need ack_seq in the skbs stored in receive queues ?
> 
> 	TCP_SKB_CB(to)->ack_seq = TCP_SKB_CB(from)->ack_seq;

Yes, it's used only for incoming ACKs.  But better safe than
sorry. :-)

Applied, thanks.
