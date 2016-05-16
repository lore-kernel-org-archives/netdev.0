From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: minor optimizations around tcp_hdr()
 usage
Date: Mon, 16 May 2016 13:47:20 -0400 (EDT)
Message-ID: <20160516.134720.895829616600822039.davem@davemloft.net>
References: <1463156200.23934.199.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36783 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754267AbcEPRrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 13:47:21 -0400
In-Reply-To: <1463156200.23934.199.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 May 2016 09:16:40 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_hdr() is slightly more expensive than using skb->data in contexts
> where we know they point to the same byte.
> 
> In receive path, tcp_v4_rcv() and tcp_v6_rcv() are in this situation,
> as tcp header has not been pulled yet.
> 
> In output path, the same can be said when we just pushed the tcp header
> in the skb, in tcp_transmit_skb() and tcp_make_synack()
> 
> Also factorize the two checks for tcb->tcp_flags & TCPHDR_SYN in
> tcp_transmit_skb() and pass tcp header pointer to tcp_ecn_send(),
> so that compiler can further optimize and avoid a reload.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
