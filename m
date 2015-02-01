From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: sched: fix panic in rate estimators
Date: Sat, 31 Jan 2015 17:55:20 -0800 (PST)
Message-ID: <20150131.175520.1521332119325954392.davem@davemloft.net>
References: <1422581412.21689.53.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32971 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbbBABzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2015 20:55:21 -0500
In-Reply-To: <1422581412.21689.53.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 29 Jan 2015 17:30:12 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Doing the following commands on a non idle network device
> panics the box instantly, because cpu_bstats gets overwritten
> by stats.
> 
> tc qdisc add dev eth0 root <your_favorite_qdisc>
> ... some traffic (one packet is enough) ...
> tc qdisc replace dev eth0 root est 1sec 4sec <your_favorite_qdisc>
 ...
> Lets play safe and not use an union : percpu 'pointers' are mostly read
> anyway, and we have typically few qdiscs per host.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Fixes: 22e0f8b9322c ("net: sched: make bstats per cpu and estimator RCU safe")

Applied and queued up for -stable, thanks Eric.
