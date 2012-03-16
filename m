From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wimax/i2400m: fix erroneous NETDEV_TX_BUSY use
Date: Fri, 16 Mar 2012 02:02:46 -0700 (PDT)
Message-ID: <20120316.020246.792440183234503872.davem@davemloft.net>
References: <1331752904.6022.53.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, inaky.perez-gonzalez@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36395 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676Ab2CPJCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2012 05:02:49 -0400
In-Reply-To: <1331752904.6022.53.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 14 Mar 2012 12:21:44 -0700

> A driver start_xmit() method cannot free skb and return NETDEV_TX_BUSY,
> since caller is going to reuse freed skb.
> 
> In fact netif_tx_stop_queue() / netif_stop_queue() is needed before
> returning NETDEV_TX_BUSY or you can trigger a ksoftirqd fatal loop.
> 
> In case of memory allocation error, only safe way is to drop the packet
> and return NETDEV_TX_OK
> 
> Also increments tx_dropped counter
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Inaky Perez-Gonzalez <inaky.perez-gonzalez@intel.com>

Applied, but Eric:

> @@ -367,38 +367,28 @@ netdev_tx_t i2400m_hard_start_xmit(struct sk_buff
> *skb,

Your mailer chopped up that line and I had to fix it up.
