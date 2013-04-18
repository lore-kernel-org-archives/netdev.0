From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: introduce TCPSpuriousRtxHostQueues SNMP
 counter
Date: Thu, 18 Apr 2013 14:57:45 -0400 (EDT)
Message-ID: <20130418.145745.1194444222242790469.davem@davemloft.net>
References: <1366303971.3205.62.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
	therbert@google.com, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751705Ab3DRS5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 14:57:47 -0400
In-Reply-To: <1366303971.3205.62.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 18 Apr 2013 09:52:51 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Host queues (Qdisc + NIC) can hold packets so long that TCP can
> eventually retransmit a packet before the first transmit even left
> the host.
> 
> Its not clear right now if we could avoid this in the first place :
> 
> - We could arm RTO timer not at the time we enqueue packets, but
>   at the time we TX complete them (tcp_wfree())
> 
> - Cancel the sending of the new copy of the packet if prior one
>   is still in queue.
> 
> This patch adds instrumentation so that we can at least see how
> often this problem happens.
> 
> TCPSpuriousRtxHostQueues SNMP counter is incremented every time
> we detect the fast clone is not yet freed in tcp_transmit_skb()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
