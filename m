From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net_sched: fix a refcount_t issue with noop_qdisc
Date: Thu, 24 Aug 2017 21:32:10 -0700 (PDT)
Message-ID: <20170824.213210.527936826990864365.davem@davemloft.net>
References: <1503634348.2499.98.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        elena.reshetova@intel.com, jhs@mojatatu.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35866 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751364AbdHYEcL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 00:32:11 -0400
In-Reply-To: <1503634348.2499.98.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Aug 2017 21:12:28 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> syzkaller reported a refcount_t warning [1]
> 
> Issue here is that noop_qdisc refcnt was never really considered as
> a true refcount, since qdisc_destroy() found TCQ_F_BUILTIN set :
> 
> if (qdisc->flags & TCQ_F_BUILTIN ||
>     !refcount_dec_and_test(&qdisc->refcnt)))
> 	return;
> 
> Meaning that all atomic_inc() we did on noop_qdisc.refcnt were not
> really needed, but harmless until refcount_t came.
> 
> To fix this problem, we simply need to not increment noop_qdisc.refcnt,
> since we never decrement it.
> 
> [1]
> refcount_t: increment on 0; use-after-free.
 ...
> Fixes: 7b9364050246 ("net, sched: convert Qdisc.refcnt from atomic_t to refcount_t")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Cc: Reshetova, Elena <elena.reshetova@intel.com>

Applied.
