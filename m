From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: introduce netdevice gso_min_segs
 attribute
Date: Mon, 06 Oct 2014 17:21:49 -0400 (EDT)
Message-ID: <20141006.172149.1596496098013953331.davem@davemloft.net>
References: <54312F50.2060608@mellanox.com>
	<1412524252.11091.3.camel@edumazet-glaptop2.roam.corp.google.com>
	<1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amirv@mellanox.com, edumazet@google.com, netdev@vger.kernel.org,
	yevgenyp@mellanox.com, ogerlitz@mellanox.com, idos@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38338 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaJFVVy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 17:21:54 -0400
In-Reply-To: <1412529087.11091.14.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 05 Oct 2014 10:11:27 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Some TSO engines might have a too heavy setup cost, that impacts
> performance on hosts sending small bursts (2 MSS per packet).
> 
> This patch adds a device gso_min_segs, allowing drivers to set
> a minimum segment size for TSO packets, according to the NIC
> performance.
> 
> Tested on a mlx4 NIC, this allows to get a ~110% increase of
> throughput when sending 2 MSS per packet.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

So exactly what value are you using for mlx4?

Because I wonder if we should just generically forfeit TSO unless
we have > 2 segments, for example.
