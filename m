From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: gro: fix possible panic in skb_gro_receive()
Date: Fri, 07 Dec 2012 14:41:19 -0500 (EST)
Message-ID: <20121207.144119.1859602274016402253.davem@davemloft.net>
References: <1354838099.10983.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57982 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932151Ab2LGTlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 14:41:20 -0500
In-Reply-To: <1354838099.10983.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Dec 2012 15:54:59 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 2e71a6f8084e (net: gro: selective flush of packets) added
> a bug for skbs using frag_list. This part of the GRO stack is rarely
> used, as it needs skb not using a page fragment for their skb->head.
> 
> Most drivers do use a page fragment, but some of them use GFP_KERNEL
> allocations for the initial fill of their RX ring buffer.
> 
> napi_gro_flush() overwrite skb->prev that was used for these skb to
> point to the last skb in frag_list.
> 
> Fix this using a separate field in struct napi_gro_cb to point to the
> last fragment.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
