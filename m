From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] mlx4: avoid unnecessary dirtying of
 critical fields
Date: Mon, 21 Nov 2016 11:33:44 -0500 (EST)
Message-ID: <20161121.113344.1752464897217831370.davem@davemloft.net>
References: <62f9c9ee-d710-7493-1094-e8ffe8aaa1ca@gmail.com>
        <1479662102.8455.361.camel@edumazet-glaptop3.roam.corp.google.com>
        <1479662676.8455.364.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ttoukan.linux@gmail.com, netdev@vger.kernel.org,
        tariqt@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53188 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753067AbcKUQf3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 11:35:29 -0500
In-Reply-To: <1479662676.8455.364.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 20 Nov 2016 09:24:36 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> While stressing a 40Gbit mlx4 NIC with busy polling, I found false
> sharing in mlx4 driver that can be easily avoided.
> 
> This patch brings an additional 7 % performance improvement in UDP_RR
> workload.
> 
> 1) If we received no frame during one mlx4_en_process_rx_cq()
>    invocation, no need to call mlx4_cq_set_ci() and/or dirty ring->cons
> 
> 2) Do not refill rx buffers if we have plenty of them.
>    This avoids false sharing and allows some bulk/batch optimizations.
>    Page allocator and its locks will thank us.
> 
> Finally, mlx4_en_poll_rx_cq() should not return 0 if it determined
> cpu handling NIC IRQ should be changed. We should return budget-1
> instead, to not fool net_rx_action() and its netdev_budget.
> 
> 
> v2: keep AVG_PERF_COUNTER(... polled) even if polled is 0
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
