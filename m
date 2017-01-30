From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] tcp: include locally failed retries in
 retransmission stats
Date: Sun, 29 Jan 2017 19:17:43 -0500 (EST)
Message-ID: <20170129.191743.1962744836477746399.davem@davemloft.net>
References: <20170128002439.128487-1-ycheng@google.com>
        <20170128002439.128487-2-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, edumazet@google.com,
        soheil@google.com
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751715AbdA3ARp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 19:17:45 -0500
In-Reply-To: <20170128002439.128487-2-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Fri, 27 Jan 2017 16:24:39 -0800

> Currently the retransmission stats are not incremented if the
> retransmit fails locally. But we always increment the other packet
> counters that track total packet/bytes sent.  Awkwardly while we
> don't count these failed retransmits in RETRANSSEGS, we do count
> them in FAILEDRETRANS.
> 
> If the qdisc is dropping many packets this could under-estimate
> TCP retransmission rate substantially from both SNMP or per-socket
> TCP_INFO stats. This patch changes this by always incrementing
> retransmission stats on retransmission attempts and failures.
> 
> Another motivation is to properly track retransmists in
> SCM_TIMESTAMPING_OPT_STATS. Since SCM_TSTAMP_SCHED collection is
> triggered in tcp_transmit_skb(), If tp->total_retrans is incremented
> after the function, we'll always mis-count by the amount of the
> latest retransmission.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Eric Dumazet <edumazet@google.com>

Also applied, thank you.
