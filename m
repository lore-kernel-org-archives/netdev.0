From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: don't abort splice() after small
 transfers
Date: Sun, 02 Dec 2012 20:24:00 -0500 (EST)
Message-ID: <20121202.202400.1802827154247759864.davem@davemloft.net>
References: <1354484967.20109.1167.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, w@1wt.eu
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33640 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754374Ab2LCBYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2012 20:24:01 -0500
In-Reply-To: <1354484967.20109.1167.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 02 Dec 2012 13:49:27 -0800

> From: Willy Tarreau <w@1wt.eu>
> 
> TCP coalescing added a regression in splice(socket->pipe) performance,
> for some workloads because of the way tcp_read_sock() is implemented.
> 
> The reason for this is the break when (offset + 1 != skb->len).
> 
> As we released the socket lock, this condition is possible if TCP stack
> added a fragment to the skb, which can happen with TCP coalescing.
> 
> So let's go back to the beginning of the loop when this happens,
> to give a chance to splice more frags per system call.
> 
> Doing so fixes the issue and makes GRO 10% faster than LRO
> on CPU-bound splice() workloads instead of the opposite.
> 
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
