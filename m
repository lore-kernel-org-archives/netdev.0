From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] macvlan: Move broadcasts into a work queue
Date: Sun, 20 Apr 2014 18:20:02 -0400 (EDT)
Message-ID: <20140420.182002.1685565462581318762.davem@davemloft.net>
References: <20140407075347.GA26461@gondor.apana.org.au>
	<20140417054559.GB23959@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbaDTWUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Apr 2014 18:20:03 -0400
In-Reply-To: <20140417054559.GB23959@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 17 Apr 2014 13:45:59 +0800

> Currently broadcasts are handled in network RX context, where
> the packets are sent through netif_rx.  This means that the number
> of macvlans will be constrained by the capacity of netif_rx.
> 
> For example, setting up 4096 macvlans practically causes all
> broadcast packets to be dropped as the default netif_rx queue
> size simply can't handle 4096 skbs being stuffed into it all
> at once.
> 
> Fundamentally, we need to ensure that the amount of work handled
> in each netif_rx backlog run is constrained.  As broadcasts are
> anything but constrained, it either needs to be limited per run
> or moved to process context.
> 
> This patch picks the second option and moves all broadcast handling
> bar the trivial case of packets going to a single interface into
> a work queue.  Obviously there also needs to be a limit on how
> many broadcast packets we postpone in this way.  I've arbitrarily
> chosen tx_queue_len of the master device as the limit (act_mirred
> also happens to use this parameter in a similar way).
> 
> In order to ensure we don't exceed the backlog queue we will use
> netif_rx_ni instead of netif_rx for broadcast packets.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
