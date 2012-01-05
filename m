From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: sfq: extend limits
Date: Thu, 05 Jan 2012 14:08:43 -0500 (EST)
Message-ID: <20120105.140843.1291740601133961995.davem@davemloft.net>
References: <1325722718.2634.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave.taht@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088Ab2AETIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2012 14:08:46 -0500
In-Reply-To: <1325722718.2634.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 05 Jan 2012 01:18:38 +0100

> SFQ as implemented in Linux is very limited, with at most 127 flows
> and limit of 127 packets. [ So if 127 flows are active, we have one
> packet per flow ]
> 
> This patch brings to SFQ following features to cope with modern needs.
> 
> - Ability to specify a smaller per flow limit of inflight packets.
>     (default value being at 127 packets)
> 
> - Ability to have up to 65408 active flows (instead of 127)
> 
> - Ability to have head drops instead of tail drops
>   (to drop old packets from a flow)
> 
> Example of use : No more than 20 packets per flow, max 8000 flows, max
> 20000 packets in SFQ qdisc, hash table of 65536 slots.
> 
> tc qdisc add ... sfq \
>         flows 8000 \
>         depth 20 \
>         headdrop \
>         limit 20000 \
> 	divisor 65536
> 
> Ram usage : 
> 
> 2 bytes per hash table entry (instead of previous 1 byte/entry)
> 32 bytes per flow on 64bit arches, instead of 384 for QFQ, so much
> better cache hit ratio.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
