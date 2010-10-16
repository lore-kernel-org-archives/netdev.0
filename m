From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: allocate skbs on local node
Date: Sat, 16 Oct 2010 11:54:13 -0700 (PDT)
Message-ID: <20101016.115413.104038999.davem@davemloft.net>
References: <1286838210.30423.128.camel@edumazet-laptop>
	<1286839363.30423.130.camel@edumazet-laptop>
	<1286859925.30423.184.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mchan@broadcom.com, eilong@broadcom.com,
	akpm@linux-foundation.org, hch@lst.de, cl@linux-foundation.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54705
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753679Ab0JPSxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:53:50 -0400
In-Reply-To: <1286859925.30423.184.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 12 Oct 2010 07:05:25 +0200

> [PATCH net-next] net: allocate skbs on local node
> 
> commit b30973f877 (node-aware skb allocation) spread a wrong habit of
> allocating net drivers skbs on a given memory node : The one closest to
> the NIC hardware. This is wrong because as soon as we try to scale
> network stack, we need to use many cpus to handle traffic and hit
> slub/slab management on cross-node allocations/frees when these cpus
> have to alloc/free skbs bound to a central node.
> 
> skb allocated in RX path are ephemeral, they have a very short
> lifetime : Extra cost to maintain NUMA affinity is too expensive. What
> appeared as a nice idea four years ago is in fact a bad one.
> 
> In 2010, NIC hardwares are multiqueue, or we use RPS to spread the load,
> and two 10Gb NIC might deliver more than 28 million packets per second,
> needing all the available cpus.
> 
> Cost of cross-node handling in network and vm stacks outperforms the
> small benefit hardware had when doing its DMA transfert in its 'local'
> memory node at RX time. Even trying to differentiate the two allocations
> done for one skb (the sk_buff on local node, the data part on NIC
> hardware node) is not enough to bring good performance.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
