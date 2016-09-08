From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] net_sched: act_mirred: full rcu conversion
Date: Thu, 8 Sep 2016 08:47:39 -0700
Message-ID: <57D1881B.6090009@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D0FF87.604@gmail.com>
 <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com, Hadar Hen Zion <hadarh@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:35443 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S938625AbcIHPrw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 11:47:52 -0400
Received: by mail-pa0-f67.google.com with SMTP id pp5so2561765pac.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 08:47:52 -0700 (PDT)
In-Reply-To: <1473348943.15733.57.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-09-08 08:35 AM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> As reported by Cong Wang, I was lazy when I did initial RCU conversion
> of tc_mirred, as I thought I could avoid allocation/freeing of a
> parameter block.
> 
> Use an intermediate object so that fast path can get a consistent
> snapshot of multiple variables (dev, action, eaction, ok_push)
> 
> Fixes: 2ee22a90c7af ("net_sched: act_mirred: remove spinlock in fast path")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: Hadar Hen Zion <hadarh@mellanox.com>
> Cc: Amir Vadai <amirva@mellanox.com>
> ---

Works for me. FWIW I find this plenty straightforward and don't really
see the need to make the hash table itself rcu friendly.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
