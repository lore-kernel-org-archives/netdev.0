From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: use a work queue to defer
 net_disable_timestamp() work
Date: Fri, 03 Feb 2017 16:18:16 -0500 (EST)
Message-ID: <20170203.161816.1608140108344194361.davem@davemloft.net>
References: <1485993583.6360.172.camel@edumazet-glaptop3.roam.corp.google.com>
        <CAM_iQpUVma3R7wGJ8T8FWyCpU9joiGM+8LSPMcV2xpJLiRD-pw@mail.gmail.com>
        <1486060295.21871.19.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, edumazet@google.com, dvyukov@google.com,
        netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53448 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752331AbdBCVSS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:18:18 -0500
In-Reply-To: <1486060295.21871.19.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 10:31:35 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Dmitry reported a warning [1] showing that we were calling 
> net_disable_timestamp() -> static_key_slow_dec() from a non
> process context.
> 
> Grabbing a mutex while holding a spinlock or rcu_read_lock()
> is not allowed.
> 
> As Cong suggested, we now use a work queue.
> 
> It is possible netstamp_clear() exits while netstamp_needed_deferred
> is not zero, but it is probably not worth trying to do better than that.
> 
> netstamp_needed_deferred atomic tracks the exact number of deferred
> decrements.
 ...
> Fixes: b90e5794c5bd ("net: dont call jump_label_dec from irq context")
> Suggested-by: Cong Wang <xiyou.wangcong@gmail.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queued up for -stable, thanks Eric.
