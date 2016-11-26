From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: properly flush delay-freed skbs
Date: Fri, 25 Nov 2016 19:49:57 -0500 (EST)
Message-ID: <20161125.194957.38657655809501652.davem@davemloft.net>
References: <1479919496.8455.509.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com,
        alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57396 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbcKZAuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:50:03 -0500
In-Reply-To: <1479919496.8455.509.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 23 Nov 2016 08:44:56 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Typical NAPI drivers use napi_consume_skb(skb) at TX completion time.
> This put skb in a percpu special queue, napi_alloc_cache, to get bulk
> frees.
> 
> It turns out the queue is not flushed and hits the NAPI_SKB_CACHE_SIZE
> limit quite often, with skbs that were queued hundreds of usec earlier.
> I measured this can take ~6000 nsec to perform one flush.
> 
> __kfree_skb_flush() can be called from two points right now :
> 
> 1) From net_tx_action(), but only for skbs that were queued to
> sd->completion_queue.
> 
>  -> Irrelevant for NAPI drivers in normal operation.
> 
> 2) From net_rx_action(), but only under high stress or if RPS/RFS has a
> pending action.
> 
> This patch changes net_rx_action() to perform the flush in all cases and
> after more urgent operations happened (like kicking remote CPUS for
> RPS/RFS).
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jesper Dangaard Brouer <brouer@redhat.com>
> Cc: Alexander Duyck <alexander.h.duyck@intel.com>

Applied.
