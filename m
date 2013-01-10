From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net_sched: more precise pkt_len computation
Date: Thu, 10 Jan 2013 14:58:38 -0800 (PST)
Message-ID: <20130110.145838.197118228027718720.davem@davemloft.net>
References: <1351239007.6537.291.camel@edumazet-glaptop>
	<1351243970.6537.321.camel@edumazet-glaptop>
	<1357857402.27446.2734.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, kaber@trash.net,
	paolo.valente@unimore.it, jhs@mojatatu.com,
	herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276Ab3AJW6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 17:58:40 -0500
In-Reply-To: <1357857402.27446.2734.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Jan 2013 14:36:42 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> One long standing problem with TSO/GSO/GRO packets is that skb->len
> doesn't represent a precise amount of bytes on wire.
> 
> Headers are only accounted for the first segment.
> For TCP, thats typically 66 bytes per 1448 bytes segment missing,
> an error of 4.5 % for normal MSS value.
> 
> As consequences :
> 
> 1) TBF/CBQ/HTB/NETEM/... can send more bytes than the assigned limits.
> 2) Device stats are slightly under estimated as well.
> 
> Fix this by taking account of headers in qdisc_skb_cb(skb)->pkt_len
> computation.
> 
> Packet schedulers should use qdisc pkt_len instead of skb->len for their
> bandwidth limitations, and TSO enabled devices drivers could use pkt_len
> if their statistics are not hardware assisted, and if they don't scratch
> skb->cb[] first word.
> 
> Both egress and ingress paths work, thanks to commit fda55eca5a
> (net: introduce skb_transport_header_was_set()) : If GRO built
> a GSO packet, it also set the transport header for us.
> 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks Eric.
