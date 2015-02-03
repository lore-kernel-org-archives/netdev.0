From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: fq: better control of DDOS traffic
Date: Mon, 02 Feb 2015 18:18:34 -0800 (PST)
Message-ID: <20150202.181834.2201965486446161539.davem@davemloft.net>
References: <1422626772.21689.90.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074AbbBCCSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 21:18:37 -0500
In-Reply-To: <1422626772.21689.90.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 30 Jan 2015 06:06:12 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> FQ has a fast path for skb attached to a socket, as it does not
> have to compute a flow hash. But for other packets, FQ being non
> stochastic means that hosts exposed to random Internet traffic
> can allocate million of flows structure (104 bytes each) pretty
> easily. Not only host can OOM, but lookup in RB trees can take
> too much cpu and memory resources.
> 
> This patch adds a new attribute, orphan_mask, that is adding
> possibility of having a stochastic hash for orphaned skb.
> 
> Its default value is 1024 slots.
> 
> This patch also handles the specific case of SYNACK messages:
> 
> They are attached to the listener socket, and therefore all map
> to a single hash bucket. If listener have set SO_MAX_PACING_RATE,
> hoping to have new accepted socket inherit this rate, SYNACK
> might be paced and even dropped.
> 
> This is very similar to an internal patch Google have used more
> than one year.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Can you document the mask value a little bit more?

For example, I don't understand why "(1024 - 1) << 1" means 1024
slots just from looking at this change.

Thanks.
