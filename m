From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] netem: use rb tree to implement the time queue
Date: Mon, 01 Jul 2013 18:08:04 -0700 (PDT)
Message-ID: <20130701.180804.2068659449166342971.davem@davemloft.net>
References: <1372430457.3301.272.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45934 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755452Ab3GBBII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 21:08:08 -0400
In-Reply-To: <1372430457.3301.272.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 28 Jun 2013 07:40:57 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Following typical setup to implement a ~100 ms RTT and big
> amount of reorders has very poor performance because netem
> implements the time queue using a linked list.
> -----------------------------------------------------------
> ETH=eth0
> IFB=ifb0
> modprobe ifb
> ip link set dev $IFB up
> tc qdisc add dev $ETH ingress 2>/dev/null
> tc filter add dev $ETH parent ffff: \
>    protocol ip u32 match u32 0 0 flowid 1:1 action mirred egress \
>    redirect dev $IFB
> ethtool -K $ETH gro off tso off gso off
> tc qdisc add dev $IFB root netem delay 50ms 10ms limit 100000
> tc qd add dev $ETH root netem delay 50ms limit 100000
> ---------------------------------------------------------
> 
> Switch netem time queue to a rb tree, so this kind of setup can work at
> high speed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>

Looks good, nice work Eric, applied.

Let's see how long that skb->{prev,next} trick holds up ;-)
