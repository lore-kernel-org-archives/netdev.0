From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fq_codel: add batch ability to fq_codel_drop()
Date: Tue, 03 May 2016 12:47:26 -0400 (EDT)
Message-ID: <20160503.124726.444969937520899163.davem@davemloft.net>
References: <1462146446.5535.236.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dave.taht@gmail.com, chromatix99@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48449 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756115AbcECQr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 May 2016 12:47:29 -0400
In-Reply-To: <1462146446.5535.236.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 01 May 2016 16:47:26 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In presence of inelastic flows and stress, we can call
> fq_codel_drop() for every packet entering fq_codel qdisc.
> 
> fq_codel_drop() is quite expensive, as it does a linear scan
> of 4 KB of memory to find a fat flow.
> Once found, it drops the oldest packet of this flow.
> 
> Instead of dropping a single packet, try to drop 50% of the backlog
> of this fat flow, with a configurable limit of 64 packets per round.
> 
> TCA_FQ_CODEL_DROP_BATCH_SIZE is the new attribute to make this
> limit configurable.
> 
> With this strategy the 4 KB search is amortized to a single cache line
> per drop [1], so fq_codel_drop() no longer appears at the top of kernel
> profile in presence of few inelastic flows.
> 
> [1] Assuming a 64byte cache line, and 1024 buckets
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dave Taht <dave.taht@gmail.com>
> Cc: Jonathan Morton <chromatix99@gmail.com>

Applied, thanks Eric.
