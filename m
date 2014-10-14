From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: fix tcp_ack() performance problem
Date: Tue, 14 Oct 2014 15:30:59 -0400 (EDT)
Message-ID: <20141014.153059.1891014679903384495.davem@davemloft.net>
References: <1413065849.9362.72.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, ncardwell@google.com,
	ycheng@google.com, vanj@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932347AbaJNTbB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2014 15:31:01 -0400
In-Reply-To: <1413065849.9362.72.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 11 Oct 2014 15:17:29 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> We worked hard to improve tcp_ack() performance, by not accessing
> skb_shinfo() in fast path (cd7d8498c9a5 tcp: change tcp_skb_pcount()
> location)
> 
> We still have one spurious access because of ACK timestamping,
> added in commit e1c8a607b281 ("net-timestamp: ACK timestamp for
> bytestreams")
> 
> By checking if sk_tsflags has SOF_TIMESTAMPING_TX_ACK set,
> we can avoid two cache line misses for the common case.
> 
> While we are at it, add two prefetchw() :
> 
> One in tcp_ack() to bring skb at the head of write queue.
> 
> One in tcp_clean_rtx_queue() loop to bring following skb,
> as we will delete skb from the write queue and dirty skb->next->prev.
> 
> Add a couple of [un]likely() clauses.
> 
> After this patch, tcp_ack() is no longer the most consuming
> function in tcp stack.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
