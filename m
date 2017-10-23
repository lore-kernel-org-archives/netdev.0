From: David Miller <davem@davemloft.net>
Subject: Re: [net] tcp: do tcp_mstamp_refresh before retransmits on TSQ
 handler
Date: Mon, 23 Oct 2017 05:46:12 +0100 (WEST)
Message-ID: <20171023.054612.413368645235190542.davem@davemloft.net>
References: <20171022041316.14560-1-den@klaipeden.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
        kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
To: den@klaipeden.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41490 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbdJWEqQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 00:46:16 -0400
In-Reply-To: <20171022041316.14560-1-den@klaipeden.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koichiro Den <den@klaipeden.com>
Date: Sun, 22 Oct 2017 13:13:16 +0900

> When retransmission on TSQ handler was introduced in the commit
> f9616c35a0d7 ("tcp: implement TSQ for retransmits"), the retransmitted
> skbs' timestamps were updated on the actual transmission. In the later
> commit 385e20706fac ("tcp: use tp->tcp_mstamp in output path"), it stops
> being done so. In the commit, the comment says "We try to refresh
> tp->tcp_mstamp only when necessary", and at present tcp_tsq_handler and
> tcp_v4_mtu_reduced applies to this. About the latter, it's okay since
> it's rare enough.
> 
> About the former, even though possible retransmissions on the tasklet
> comes just after the destructor run in NET_RX softirq handling, the time
> between them could be nonnegligibly large to the extent that
> tcp_rack_advance or rto rearming be affected if other (remaining) RX,
> BLOCK and (preceding) TASKLET sofirq handlings are unexpectedly heavy.
> 
> So in the same way as tcp_write_timer_handler does, doing tcp_mstamp_refresh
> ensures the accuracy of algorithms relying on it.
> 
> Fixes: 385e20706fac ("tcp: use tp->tcp_mstamp in output path")
> Signed-off-by: Koichiro Den <den@klaipeden.com>
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.
