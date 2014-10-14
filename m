From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix ooo_okay setting vs Small Queues
Date: Tue, 14 Oct 2014 13:12:20 -0400 (EDT)
Message-ID: <20141014.131220.305958099471977918.davem@davemloft.net>
References: <1412989595.9362.30.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42817 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753837AbaJNRMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 13:12:23 -0400
In-Reply-To: <1412989595.9362.30.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Oct 2014 18:06:35 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> TCP Small Queues (tcp_tsq_handler()) can hold one reference on
> sk->sk_wmem_alloc, preventing skb->ooo_okay being set.
> 
> We should relax test done to set skb->ooo_okay to take care
> of this extra reference.
> 
> Minimal truesize of skb containing one byte of payload is
> SKB_TRUESIZE(1)
> 
> Without this fix, we have more chance locking flows into the wrong
> transmit queue.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
