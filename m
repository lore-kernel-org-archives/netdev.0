From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: prepare skbs for better sack shifting
Date: Sat, 17 Sep 2016 10:05:27 -0400 (EDT)
Message-ID: <20160917.100527.590702360910250037.davem@davemloft.net>
References: <1473957182.22679.50.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycheng@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60166 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751258AbcIQOFa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 10:05:30 -0400
In-Reply-To: <1473957182.22679.50.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Sep 2016 09:33:02 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> With large BDP TCP flows and lossy networks, it is very important
> to keep a low number of skbs in the write queue.
> 
> RACK and SACK processing can perform a linear scan of it.
> 
> We should avoid putting any payload in skb->head, so that SACK
> shifting can be done if needed.
> 
> With this patch, we allow to pack ~0.5 MB per skb instead of
> the 64KB initially cooked at tcp_sendmsg() time.
> 
> This gives a reduction of number of skbs in write queue by eight.
> tcp_rack_detect_loss() likes this.
> 
> We still allow payload in skb->head for first skb put in the queue,
> to not impact RPC workloads.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Yuchung Cheng <ycheng@google.com>

Applied.
