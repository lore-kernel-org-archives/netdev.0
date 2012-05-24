From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: take care of overlaps in tcp_try_coalesce()
Date: Thu, 24 May 2012 00:27:42 -0400 (EDT)
Message-ID: <20120524.002742.1295533350623902945.davem@davemloft.net>
References: <1337798274.3361.3234.camel@edumazet-glaptop>
	<CAJyhjX1UW=N0B9GFMt_u_gFEsLH2=8OJx0N7zJWVCrpic5Z9kQ@mail.gmail.com>
	<1337831497.3361.3888.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lists@uece.net, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179Ab2EXE1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2012 00:27:45 -0400
In-Reply-To: <1337831497.3361.3888.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 May 2012 05:51:37 +0200

> [PATCH] tcp: take care of overlaps in tcp_try_coalesce()
> 
> Sergio Correia reported following warning :
> 
> WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x4f/0x110()
> 
> WARN(skb && !before(tp->copied_seq, TCP_SKB_CB(skb)->end_seq),
>      "cleanup rbuf bug: copied %X seq %X rcvnxt %X\n",
>      tp->copied_seq, TCP_SKB_CB(skb)->end_seq, tp->rcv_nxt);
> 
> It appears TCP coalescing, and more specifically commit b081f85c297
> (net: implement tcp coalescing in tcp_queue_rcv()) should take care of
> possible segment overlaps in receive queue. This was properly done in
> the case of out_or_order_queue by the caller.
> 
> For example, segment at tail of queue have sequence 1000-2000, and we
> add a segment with sequence 1500-2500.
> This can happen in case of retransmits.
> 
> In this case, just don't do the coalescing.
> 
> Reported-by: Sergio Correia <lists@uece.net>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Sergio Correia <lists@uece.net>

Applied, thanks.
