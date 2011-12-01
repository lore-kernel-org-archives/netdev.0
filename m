From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] sch_red: fix red_calc_qavg_from_idle_time
Date: Wed, 30 Nov 2011 23:29:00 -0500 (EST)
Message-ID: <20111130.232900.500559159038300107.davem@davemloft.net>
References: <1322688891.2602.15.camel@edumazet-laptop>
	<1322689213.2602.18.camel@edumazet-laptop>
	<1322691053.2602.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, dave.taht@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58341 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753451Ab1LAE3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:29:03 -0500
In-Reply-To: <1322691053.2602.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Nov 2011 23:10:53 +0100

> Since commit a4a710c4a7490587 (pkt_sched: Change PSCHED_SHIFT from 10 to
> 6) it seems RED/GRED are broken.
> 
> red_calc_qavg_from_idle_time() computes a delay in us units, but this
> delay is now 16 times bigger than real delay, so the final qavg result
> smaller than expected.
> 
> Use standard kernel time services since there is no need to obfuscate
> them.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks Eric.

If someone is looking for a fun project, I would like to see
psched_t obliterated completely and replaced with ktime_t across
the board.

To be honest, psched_t was created exactly because at the time we
lacked something like ktime_t.
