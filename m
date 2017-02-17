From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mlx4: do not fire tasklet unless necessary
Date: Fri, 17 Feb 2017 10:55:54 -0500 (EST)
Message-ID: <20170217.105554.1471478837157578274.davem@davemloft.net>
References: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tariqt@mellanox.com, saeedm@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44428 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934200AbdBQP4A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 10:56:00 -0500
In-Reply-To: <1486729678.7793.139.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 10 Feb 2017 04:27:58 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> All rx and rx netdev interrupts are handled by respectively
> by mlx4_en_rx_irq() and mlx4_en_tx_irq() which simply schedule a NAPI.
> 
> But mlx4_eq_int() also fires a tasklet to service all items that were
> queued via mlx4_add_cq_to_tasklet(), but this handler was not called
> unless user cqe was handled.
> 
> This is very confusing, as "mpstat -I SCPU ..." show huge number of
> tasklet invocations.
> 
> This patch saves this overhead, by carefully firing the tasklet directly
> from mlx4_add_cq_to_tasklet(), removing four atomic operations per IRQ.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
