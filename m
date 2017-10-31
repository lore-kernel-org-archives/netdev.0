From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] net_sched: remove tcf_block_put_deferred()
Date: Tue, 31 Oct 2017 11:06:55 +0900 (KST)
Message-ID: <20171031.110655.1489377013029699670.davem@davemloft.net>
References: <20171030181009.18340-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, jiri@resnulli.us,
        john.fastabend@gmail.com, jhs@mojatatu.com,
        paulmck@linux.vnet.ibm.com, edumazet@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50696 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbdJaCG7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 22:06:59 -0400
In-Reply-To: <20171030181009.18340-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 30 Oct 2017 11:10:09 -0700

> In commit 7aa0045dadb6 ("net_sched: introduce a workqueue for RCU callbacks of tc filter")
> I defer tcf_chain_flush() to a workqueue, this causes a use-after-free
> because qdisc is already destroyed after we queue this work.
> 
> The tcf_block_put_deferred() is no longer necessary after we get RTNL
> for each tc filter destroy work, no others could jump in at this point.
> Same for tcf_chain_hold(), we are fully serialized now.
> 
> This also reduces one indirection therefore makes the code more
> readable. Note this brings back a rcu_barrier(), however comparing
> to the code prior to commit 7aa0045dadb6 we still reduced one
> rcu_barrier(). For net-next, we can consider to refcnt tcf block to
> avoid it.
> 
> Fixes: 7aa0045dadb6 ("net_sched: introduce a workqueue for RCU callbacks of tc filter")
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Jiri Pirko <jiri@resnulli.us>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks for fixing this use-after-free so quickly.

This will be another fun merge into net-next :-)
