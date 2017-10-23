From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net 00/15] net_sched: remove RCU callbacks from TC
Date: Mon, 23 Oct 2017 16:16:39 -0700
Message-ID: <1508800599.30291.106.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
        jhs@mojatatu.com, john.fastabend@gmail.com,
        Chris Mi <chrism@mellanox.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:54156 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751116AbdJWXQl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 19:16:41 -0400
Received: by mail-it0-f66.google.com with SMTP id n195so7911289itg.2
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 16:16:41 -0700 (PDT)
In-Reply-To: <20171023220304.2268-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-10-23 at 15:02 -0700, Cong Wang wrote:

> b) As suggested by Paul, we could defer the work to a workqueue and
> gain the permission of holding RTNL again without any performance
> impact, however, this seems impossible too, because as lockdep
> complains we have a deadlock when flushing workqueue while hodling
> RTNL lock, see the rcu_barrier() in tcf_block_put().
> 
> Therefore, the simplest solution we have is probably just getting
> rid of these RCU callbacks, because they are not necessary at all,
> callers of these call_rcu() are all on slow paths and have RTNL
> lock, so blocking is allowed in their contexts.

I am against these pessimistic changes, sorry for not following past
discussions last week.

I am asking a talk during upcoming netdev/netconf about this, if we need
to take a decision.

RTNL is already a big problem for many of us, adding synchronize_rcu()
calls while holding RTNL is a no - go, unless we have clear evidence it
can not be avoided.

Thanks !
