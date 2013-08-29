From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] tcp: TSO packets automatic sizing
Date: Thu, 29 Aug 2013 15:51:31 -0400 (EDT)
Message-ID: <20130829.155131.1753610025310087003.davem@davemloft.net>
References: <1377304192.8828.43.camel@edumazet-glaptop>
	<1377491162.8828.116.camel@edumazet-glaptop>
	<1377607592.8828.149.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	vanj@google.com, therbert@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37521 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754973Ab3H2Tvg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 15:51:36 -0400
In-Reply-To: <1377607592.8828.149.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 27 Aug 2013 05:46:32 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> After hearing many people over past years complaining against TSO being
> bursty or even buggy, we are proud to present automatic sizing of TSO
> packets.
> 
> One part of the problem is that tcp_tso_should_defer() uses an heuristic
> relying on upcoming ACKS instead of a timer, but more generally, having
> big TSO packets makes little sense for low rates, as it tends to create
> micro bursts on the network, and general consensus is to reduce the
> buffering amount.
> 
> This patch introduces a per socket sk_pacing_rate, that approximates
> the current sending rate, and allows us to size the TSO packets so
> that we try to send one packet every ms.
> 
> This field could be set by other transports.
> 
> Patch has no impact for high speed flows, where having large TSO packets
> makes sense to reach line rate.
> 
> For other flows, this helps better packet scheduling and ACK clocking.
> 
> This patch increases performance of TCP flows in lossy environments.
> 
> A new sysctl (tcp_min_tso_segs) is added, to specify the
> minimal size of a TSO packet (default being 2).
> 
> A follow-up patch will provide a new packet scheduler (FQ), using
> sk_pacing_rate as an input to perform optional per flow pacing.
> 
> This explains why we chose to set sk_pacing_rate to twice the current
> rate, allowing 'slow start' ramp up.
> 
> sk_pacing_rate = 2 * cwnd * mss / srtt
>  
> v2: Neal Cardwell reported a suspect deferring of last two segments on
> initial write of 10 MSS, I had to change tcp_tso_should_defer() to take
> into account tp->xmit_size_goal_segs 
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, please post a new copy of your accompanying packet scheduler.

Thanks.
