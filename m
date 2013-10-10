From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: gro: allow to build full sized skb
Date: Thu, 10 Oct 2013 00:17:52 -0400 (EDT)
Message-ID: <20131010.001752.22220460519005332.davem@davemloft.net>
References: <1381248143.12191.53.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56161 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751791Ab3JJERx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 00:17:53 -0400
In-Reply-To: <1381248143.12191.53.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 08 Oct 2013 09:02:23 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> skb_gro_receive() is currently limited to 16 or 17 MSS per GRO skb,
> typically 24616 bytes, because it fills up to MAX_SKB_FRAGS frags.
> 
> It's relatively easy to extend the skb using frag_list to allow
> more frags to be appended into the last sk_buff.
> 
> This still builds very efficient skbs, and allows reaching 45 MSS per
> skb.
> 
> (45 MSS GRO packet uses one skb plus a frag_list containing 2 additional
> sk_buff)
> 
> High speed TCP flows benefit from this extension by lowering TCP stack
> cpu usage (less packets stored in receive queue, less ACK packets
> processed)
> 
> Forwarding setups could be hurt, as such skbs will need to be
> linearized, although its not a new problem, as GRO could already
> provide skbs with a frag_list.
> 
> We could make the 65536 bytes threshold a tunable to mitigate this.
> 
> (First time we need to linearize skb in skb_needs_linearize(), we could
> lower the tunable to ~16*1460 so that following skb_gro_receive() calls
> build smaller skbs)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
