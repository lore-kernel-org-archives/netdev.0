From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: do not use cached RTT for RTT estimation
Date: Fri, 30 Aug 2013 15:16:28 -0400 (EDT)
Message-ID: <20130830.151628.461053901383945392.davem@davemloft.net>
References: <1377876953.7360.10.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com, edumazet@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753127Ab3H3TQa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Aug 2013 15:16:30 -0400
In-Reply-To: <1377876953.7360.10.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Aug 2013 08:35:53 -0700

> From: Yuchung Cheng <ycheng@google.com>
> 
> RTT cached in the TCP metrics are valuable for the initial timeout
> because SYN RTT usually does not account for serialization delays
> on low BW path.
> 
> However using it to seed the RTT estimator maybe disruptive because
> other components (e.g., pacing) require the smooth RTT to be obtained
> from actual connection.
> 
> The solution is to use the higher cached RTT to set the first RTO
> conservatively like tcp_rtt_estimator(), but avoid seeding the other
> RTT estimator variables such as srtt.  It is also a good idea to
> keep RTO conservative to obtain the first RTT sample, and the
> performance is insured by TCP loss probe if SYN RTT is available.
> 
> To keep the seeding formula consistent across SYN RTT and cached RTT,
> the rttvar is twice the cached RTT instead of cached RTTVAR value. The
> reason is because cached variation may be too small (near min RTO)
> which defeats the purpose of being conservative on first RTO. However
> the metrics still keep the RTT variations as they might be useful for
> user applications (through ip).
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Eric Dumazet <edumazet@google.com>

Applied, but in one aspect I am disappointed.

You removed Alexey Kuznetsov's detailed comment about what is going
on here, but did not replace it with a new comment explaining in
detail the new logic.

In particular we need a comment showing exactly what happens as we
get the initial RTT measurement for the SYN/SYN-ACK, and then an
explanation the transition which now occurs when we move into the
RTT measurements after the handshake.

Could you write something up?

Thank you.
