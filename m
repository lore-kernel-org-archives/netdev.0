From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] ipvlan: fix various issues in
 ipvlan_process_multicast()
Date: Thu, 22 Dec 2016 11:20:28 -0500 (EST)
Message-ID: <20161222.112028.2305636805598303877.davem@davemloft.net>
References: <1482355800.8944.75.camel@edumazet-glaptop3.roam.corp.google.com>
        <1482372024.8944.79.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46686 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S966065AbcLVQUa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Dec 2016 11:20:30 -0500
In-Reply-To: <1482372024.8944.79.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 21 Dec 2016 18:00:24 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> 1) netif_rx() / dev_forward_skb() should not be called from process
> context.
> 
> 2) ipvlan_count_rx() should be called with preemption disabled.
> 
> 3) We should check if ipvlan->dev is up before feeding packets
> to netif_rx()
> 
> 4) We need to prevent device from disappearing if some packets
> are in the multicast backlog.
> 
> 5) One kfree_skb() should be a consume_skb() eventually
> 
> Fixes: ba35f8588f47 ("ipvlan: Defer multicast / broadcast processing to
> a work-queue")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>

Applied.
