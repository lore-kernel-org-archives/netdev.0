From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC Patch net-next 5/6] net_sched: use rcu in fast path
Date: Thu, 8 Sep 2016 08:49:40 -0700
Message-ID: <57D18894.2070702@gmail.com>
References: <1472795840-31901-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472795840-31901-6-git-send-email-xiyou.wangcong@gmail.com>
 <1473173528.10725.14.camel@edumazet-glaptop3.roam.corp.google.com>
 <57D0FF87.604@gmail.com>
 <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org,
        jhs@mojatatu.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35025 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932283AbcIHPtu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 11:49:50 -0400
Received: by mail-pf0-f195.google.com with SMTP id n24so2673589pfb.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 08:49:50 -0700 (PDT)
In-Reply-To: <1473341283.15733.33.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

>>
>> So its at least possible I think these could be interleaved on multiple
>> cpus.
> 
> Sure, this was very clear when I wrote this code. Otherwise I would have
> used an intermediate object and one rcu_dereference() instead of the
> READ_ONCE().
> 
> 
>>
>> Notice that some of the actions are fine though and don't have this
>> issue act_bpf for example is fine.
>>
>> I think we can either fix it in the hash table create part of the
>> list as this series does or just let each action handle it on its own.
> 
> If we want a fix for stable kernels we want a tc_mirred fix on its own,
> and I was planning to do so.
> 
> Given that a "tc qdisc replace ..." drops all packets sitting in the old
> qdisc, I never thought someone would actually depend on atomically
> switching tc_mirred parameters. I for sure did not care.
> 
> Thanks.
> 
> 

Agreed not sure why you would ever want to do a late binding and
replace on a tc_mirred actions. But it is supported...
