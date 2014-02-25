From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: reduce the bloat caused by
 tcp_is_cwnd_limited()
Date: Mon, 24 Feb 2014 19:14:23 -0500 (EST)
Message-ID: <20140224.191423.1857998272406050896.davem@davemloft.net>
References: <1393105959.2316.30.camel@edumazet-glaptop2.roam.corp.google.com>
	<1393136757.2316.39.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, ncardwell@google.com,
	nanditad@google.com, vanj@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbaBYAOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 19:14:25 -0500
In-Reply-To: <1393136757.2316.39.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 22 Feb 2014 22:25:57 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> tcp_is_cwnd_limited() allows GSO/TSO enabled flows to increase
> their cwnd to allow a full size (64KB) TSO packet to be sent.
> 
> Non GSO flows only allow an extra room of 3 MSS.
> 
> For most flows with a BDP below 10 MSS, this results in a bloat
> of cwnd reaching 90, and an inflate of RTT.
> 
> Thanks to TSO auto sizing, we can restrict the bloat to the number
> of MSS contained in a TSO packet (tp->xmit_size_goal_segs), to keep
> original intent without performance impact.
> 
> Because we keep cwnd small, it helps to keep TSO packet size to their
> optimal value.
> 
> Example for a 10Mbit flow, with low TCP Small queue limits (no more than
> 2 skb in qdisc/device tx ring)
> 
> Before patch :
> 
> lpk51:~# ./ss -i dst lpk52:44862 | grep cwnd
>          cubic wscale:6,6 rto:215 rtt:15.875/2.5 mss:1448 cwnd:96
> ssthresh:96
> send 70.1Mbps unacked:14 rcv_space:29200
> 
> After patch :
> 
> lpk51:~# ./ss -i dst lpk52:52916 | grep cwnd
>          cubic wscale:6,6 rto:206 rtt:5.206/0.036 mss:1448 cwnd:15
> ssthresh:14
> send 33.4Mbps unacked:4 rcv_space:29200
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
