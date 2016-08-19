From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: refine tcp_prune_ofo_queue() to not drop
 all packets
Date: Thu, 18 Aug 2016 23:36:43 -0700 (PDT)
Message-ID: <20160818.233643.732250691565806768.davem@davemloft.net>
References: <1471468629.29842.39.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, ncardwell@google.com,
        ycheng@google.com, csg@google.com, vanj@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42454 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753413AbcHSGhR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2016 02:37:17 -0400
In-Reply-To: <1471468629.29842.39.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Aug 2016 14:17:09 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Over the years, TCP BDP has increased a lot, and is typically
> in the order of ~10 Mbytes with help of clever Congestion Control
> modules.
> 
> In presence of packet losses, TCP stores incoming packets into an out of
> order queue, and number of skbs sitting there waiting for the missing
> packets to be received can match the BDP (~10 Mbytes)
> 
> In some cases, TCP needs to make room for incoming skbs, and current
> strategy can simply remove all skbs in the out of order queue as a last
> resort, incurring a huge penalty, both for receiver and sender.
> 
> Unfortunately these 'last resort events' are quite frequent, forcing
> sender to send all packets again, stalling the flow and wasting a lot of
> resources.
> 
> This patch cleans only a part of the out of order queue in order
> to meet the memory constraints.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks great, applied.
