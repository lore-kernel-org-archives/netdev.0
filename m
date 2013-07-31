From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netem: Introduce skb_orphan_partial() helper
Date: Wed, 31 Jul 2013 15:00:20 -0700 (PDT)
Message-ID: <20130731.150020.1079928001574422468.davem@davemloft.net>
References: <1375232108.10515.47.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33685 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753732Ab3GaWAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 18:00:22 -0400
In-Reply-To: <1375232108.10515.47.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Jul 2013 17:55:08 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 547669d483e578 ("tcp: xps: fix reordering issues") added
> unexpected reorders in case netem is used in a MQ setup for high
> performance test bed.
> 
> ETH=eth0
> tc qd del dev $ETH root 2>/dev/null
> tc qd add dev $ETH root handle 1: mq
> for i in `seq 1 32`
> do
>  tc qd add dev $ETH parent 1:$i netem delay 100ms
> done
> 
> As all tcp packets are orphaned by netem, TCP stack believes it can
> set skb->ooo_okay on all packets.
> 
> In order to allow producers to send more packets, we want to 
> keep sk_wmem_alloc from reaching sk_sndbuf limit.
> 
> We can do that by accounting one byte per skb in netem queues,
> so that TCP stack is not fooled too much.
 ...
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
