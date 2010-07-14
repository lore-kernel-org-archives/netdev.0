From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: skb_tx_hash() fix relative to skb_orphan_try()
Date: Wed, 14 Jul 2010 15:33:51 -0700 (PDT)
Message-ID: <20100714.153351.226785072.davem@davemloft.net>
References: <1279034660.2634.439.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49325
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757946Ab0GNWdg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 18:33:36 -0400
In-Reply-To: <1279034660.2634.439.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Jul 2010 17:24:20 +0200

> commit fc6055a5ba31e2 (net: Introduce skb_orphan_try()) added early
> orphaning of skbs.
> 
> This unfortunately added a performance regression in skb_tx_hash() in
> case of stacked devices (bonding, vlans, ...)
> 
> Since skb->sk is now NULL, we cannot access sk->sk_hash anymore to
> spread tx packets to multiple NIC queues on multiqueue devices.
> 
> skb_tx_hash() in this case only uses skb->protocol, same value for all
> flows.
> 
> skb_orphan_try() can copy sk->sk_hash into skb->rxhash and skb_tx_hash()
> can use this saved sk_hash value to compute its internal hash value.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks Eric.
