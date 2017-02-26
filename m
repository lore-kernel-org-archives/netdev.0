From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/mlx4_en: fix overflow in
 mlx4_en_init_timestamp()
Date: Sun, 26 Feb 2017 15:45:44 -0500 (EST)
Message-ID: <20170226.154544.2016858795928257220.davem@davemloft.net>
References: <1487892163.9415.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eugenia@mellanox.com, tariqt@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751221AbdBZUpx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 26 Feb 2017 15:45:53 -0500
In-Reply-To: <1487892163.9415.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 23 Feb 2017 15:22:43 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> The cited commit makes a great job of finding optimal shift/multiplier
> values assuming a 10 seconds wrap around, but forgot to change the
> overflow_period computation.
> 
> It overflows in cyclecounter_cyc2ns(), and the final result is 804 ms,
> which is silly.
> 
> Lets simply use 5 seconds, no need to recompute this, given how it is
> supposed to work.
> 
> Later, we will use a timer instead of a work queue, since the new RX
> allocation schem will no longer need mlx4_en_recover_from_oom() and the
> service_task firing every 250 ms.
> 
> Fixes: 31c128b66e5b ("net/mlx4_en: Choose time-stamping shift value according to HW frequency")
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
