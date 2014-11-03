From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: less interrupt masking in NAPI
Date: Mon, 03 Nov 2014 12:25:38 -0500 (EST)
Message-ID: <20141103.122538.387451917276174830.davem@davemloft.net>
References: <1414937973.31792.37.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47645 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752528AbaKCRZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 12:25:40 -0500
In-Reply-To: <1414937973.31792.37.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 02 Nov 2014 06:19:33 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> net_rx_action() can mask irqs a single time to transfert sd->poll_list
> into a private list, for a very short duration.
> 
> Then, napi_complete() can avoid masking irqs again,
> and net_rx_action() only needs to mask irq again in slow path.
> 
> This patch removes 2 couples of irq mask/unmask per typical NAPI run,
> more if multiple napi were triggered.
> 
> Note this also allows to give control back to caller (do_softirq())
> more often, so that other softirq handlers can be called a bit earlier,
> or ksoftirqd can be wakeup earlier under pressure.
> 
> This was developed while testing an alternative to RX interrupt
> mitigation to reduce latencies while keeping or improving GRO
> aggregation on fast NIC.
> 
> Idea is to test napi->gro_list at the end of a napi->poll() and
> reschedule one NAPI poll, but after servicing a full round of
> softirqs (timers, TX, rcu, ...). This will be allowed only if softirq
> is currently serviced by idle task or ksoftirqd, and resched not needed.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Also applied, thanks Eric.
