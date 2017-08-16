From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fix NULL dereference in free_fib_info_rcu()
Date: Tue, 15 Aug 2017 17:14:24 -0700 (PDT)
Message-ID: <20170815.171424.754423204914655743.davem@davemloft.net>
References: <1502799977.4936.71.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44030 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752328AbdHPAOZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 20:14:25 -0400
In-Reply-To: <1502799977.4936.71.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 15 Aug 2017 05:26:17 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> If fi->fib_metrics could not be allocated in fib_create_info()
> we attempt to dereference a NULL pointer in free_fib_info_rcu() :
> 
>     m = fi->fib_metrics;
>     if (m != &dst_default_metrics && atomic_dec_and_test(&m->refcnt))
>             kfree(m);
> 
> Before my recent patch, we used to call kfree(NULL) and nothing wrong
> happened.
> 
> Instead of using RCU to defer freeing while we are under memory stress,
> it seems better to take immediate action.
> 
> This was reported by syzkaller team.
> 
> Fixes: 3fb07daff8e9 ("ipv4: add reference counting to metrics")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable.
