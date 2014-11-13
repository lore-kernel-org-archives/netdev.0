From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: limit GSO packets to half cwnd
Date: Thu, 13 Nov 2014 15:22:02 -0500 (EST)
Message-ID: <20141113.152202.1381528737325236329.davem@davemloft.net>
References: <1415900722.17262.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	nanditad@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59243 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933852AbaKMUWE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 15:22:04 -0500
In-Reply-To: <1415900722.17262.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 13 Nov 2014 09:45:22 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> In DC world, GSO packets initially cooked by tcp_sendmsg() are usually
> big, as sk_pacing_rate is high.
> 
> When network is congested, cwnd can be smaller than the GSO packets
> found in socket write queue. tcp_write_xmit() splits GSO packets
> using the available cwnd, and we end up sending a single GSO packet,
> consuming all available cwnd.
> 
> With GRO aggregation on the receiver, we might handle a single GRO
> packet, sending back a single ACK.
> 
> 1) This single ACK might be lost
>    TLP or RTO are forced to attempt a retransmit.
> 2) This ACK releases a full cwnd, sender sends another big GSO packet,
>    in a ping pong mode.
> 
> This behavior does not fill the pipes in the best way, because of
> scheduling artifacts.
> 
> Make sure we always have at least two GSO packets in flight.
> 
> This allows us to safely increase GRO efficiency without risking
> spurious retransmits.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

This looks fantastic, applied, thanks Eric!
