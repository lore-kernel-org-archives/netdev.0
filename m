From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: gro: fix PV6_GRO_CB(skb)->proto problem
Date: Mon, 08 Oct 2012 15:41:48 -0400 (EDT)
Message-ID: <20121008.154148.2288526275691661749.davem@davemloft.net>
References: <1349725130.21172.3663.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57384 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072Ab2JHTlv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2012 15:41:51 -0400
In-Reply-To: <1349725130.21172.3663.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Oct 2012 21:38:50 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> It seems IPV6_GRO_CB(skb)->proto can be destroyed in skb_gro_receive()
> if a new skb is allocated (to serve as an anchor for frag_list)
> 
> We copy NAPI_GRO_CB() only (not the IPV6 specific part) in :
> 
> *NAPI_GRO_CB(nskb) = *NAPI_GRO_CB(p);
> 
> So we leave IPV6_GRO_CB(nskb)->proto to 0 (fresh skb allocation) instead
> of IPPROTO_TCP (6)
> 
> ipv6_gro_complete() isnt able to call ops->gro_complete()
> [ tcp6_gro_complete() ]
> 
> Fix this by moving proto in NAPI_GRO_CB() and getting rid of
> IPV6_GRO_CB
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>

Applied and queued up for -stable, thanks Eric.
