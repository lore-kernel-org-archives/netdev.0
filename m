From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tg3: switch to build_skb() infrastructure
Date: Mon, 21 Nov 2011 16:11:16 -0500 (EST)
Message-ID: <20111121.161116.13047257344687921.davem@davemloft.net>
References: <1321634821.3277.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, mchan@broadcom.com,
	mcarlson@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753501Ab1KUVLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 16:11:20 -0500
In-Reply-To: <1321634821.3277.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Nov 2011 17:47:01 +0100

> This is very similar to bnx2x conversion, but simpler since no special
> alignement is required, so goal was not to reduce skb truesize.
> 
> Using build_skb() reduces cache line misses in the driver, since we
> use cache hot skb instead of cold ones. Number of in-flight sk_buff
> structures is lower, they are more likely recycled in SLUB caches
> while still hot.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Matt Carlson <mcarlson@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> CC: Eilon Greenstein <eilong@broadcom.com>

I've applied this because I know Eric gave it a good testing :-)

I really like how the build_skb() interface allows us to overlap
the prefetch of skb->data with the allocation of the SKB metadata.
