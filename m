From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] pkt_sched: fq: fix pacing for small frames
Date: Fri, 15 Nov 2013 21:06:43 -0500 (EST)
Message-ID: <20131115.210643.1050495716712111997.davem@davemloft.net>
References: <1384534694.28716.77.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maze@google.com, willemb@google.com,
	ycheng@google.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32841 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753200Ab3KPCGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 21:06:45 -0500
In-Reply-To: <1384534694.28716.77.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Nov 2013 08:58:14 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> For performance reasons, sch_fq tried hard to not setup timers for every
> sent packet, using a quantum based heuristic : A delay is setup only if
> the flow exhausted its credit.
> 
> Problem is that application limited flows can refill their credit
> for every queued packet, and they can evade pacing.
> 
> This problem can also be triggered when TCP flows use small MSS values,
> as TSO auto sizing builds packets that are smaller than the default fq
> quantum (3028 bytes) 
> 
> This patch adds a 40 ms delay to guard flow credit refill.
> 
> Fixes: afe4fd062416 ("pkt_sched: fq: Fair Queue packet scheduler")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable.

Thanks.
