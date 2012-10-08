From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: gro: selective flush of packets
Date: Mon, 08 Oct 2012 14:52:16 -0400 (EDT)
Message-ID: <20121008.145216.988125819977620502.davem@davemloft.net>
References: <1349506825.21172.241.camel@edumazet-glaptop>
	<20121006105618.GA28591@gondor.apana.org.au>
	<1349546929.21172.1598.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	jesse@nicira.com, therbert@google.com, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480Ab2JHSwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 14:52:19 -0400
In-Reply-To: <1349546929.21172.1598.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 06 Oct 2012 20:08:49 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Current GRO can hold packets in gro_list for almost unlimited
> time, in case napi->poll() handler consumes its budget over and over.
> 
> In this case, napi_complete()/napi_gro_flush() are not called.
> 
> Another problem is that gro_list is flushed in non friendly way :
> We scan the list and complete packets in the reverse order.
> (youngest packets first, oldest packets last)
> This defeats priorities that sender could have cooked.
> 
> Since GRO currently only store TCP packets, we dont really notice the
> bug because of retransmits, but this behavior can add unexpected
> latencies, particularly on mice flows clamped by elephant flows.
> 
> This patch makes sure no packet can stay more than 1 ms in queue, and
> only in stress situations.
> 
> It also complete packets in the right order to minimize latencies.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
