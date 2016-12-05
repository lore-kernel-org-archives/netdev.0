From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next] net_sched: gen_estimator: complete rewrite
 of rate estimators
Date: Mon, 05 Dec 2016 15:22:23 -0500 (EST)
Message-ID: <20161205.152223.2283744541131458900.davem@davemloft.net>
References: <1480835273.18162.457.camel@edumazet-glaptop3.roam.corp.google.com>
        <1480835882.18162.462.camel@edumazet-glaptop3.roam.corp.google.com>
        <1480873696.18162.470.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1480873696.18162.470.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 04 Dec 2016 09:48:16 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> 1) Old code was hard to maintain, due to complex lock chains.
>    (We probably will be able to remove some kfree_rcu() in callers)
> 
> 2) Using a single timer to update all estimators does not scale.
> 
> 3) Code was buggy on 32bit kernel (WRITE_ONCE() on 64bit quantity
>    is not supposed to work well)
> 
> In this rewrite :
> 
> - I removed the RB tree that had to be scanned in
>   gen_estimator_active(). qdisc dumps should be much faster.
> 
> - Each estimator has its own timer.
> 
> - Estimations are maintained in net_rate_estimator structure,
>   instead of dirtying the qdisc. Minor, but part of the simplification.
> 
> - Reading the estimator uses RCU and a seqcount to provide proper
>   support for 32bit kernels.
> 
> - We reduce memory need when estimators are not used, since
>   we store a pointer, instead of the bytes/packets counters.
> 
> - xt_rateest_mt() no longer has to grab a spinlock.
>   (In the future, xt_rateest_tg() could be switched to per cpu counters)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> v3: Renamed some parameters to please make htmldocs
> v2: Removed unwanted changes to tcp_output.c

This was probably long overdue, thanks for working on this.

Applied, thanks Eric.
