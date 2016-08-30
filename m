From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH v3 net-next 1/1] net_sched: Introduce skbmod action
Date: Tue, 30 Aug 2016 07:12:20 -0400
Message-ID: <2a6e36a6-f128-ba9d-4d69-90ff5383fb75@mojatatu.com>
References: <1472386756-23085-1-git-send-email-jhs@emojatatu.com>
 <1472400467.14381.252.camel@edumazet-glaptop3.roam.corp.google.com>
 <b075631d-92cc-d016-3786-aaacb3d5c13a@mojatatu.com>
 <b117fac2-c73f-2d42-3843-52f9717224d9@mojatatu.com>
 <1472494817.14381.267.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, daniel@iogearbox.net,
        xiyou.wangcong@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:33693 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757848AbcH3LMa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 07:12:30 -0400
Received: by mail-it0-f65.google.com with SMTP id n75so1712338ith.0
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 04:12:30 -0700 (PDT)
In-Reply-To: <1472494817.14381.267.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-29 02:20 PM, Eric Dumazet wrote:

>
> You would need to store everything in an object, managed by rcu.
>
> struct my_rcu_safe_struct {
>      u32 flags;
>      u8   eth_dst[ETH_ALEN];
>      u8   eth_src[ETH_ALEN];
>      __be16 eth_type;
> };
>
> And then allocate a new one when you need to update the infos (from
> tcf_skbmod_init(())
>
> RCU : Read Copy Update.
>
> Then in the reader you would use
>
> rcu_read_lock();
> myptr = rcu_dereference(d->ptr);
> if (myptr) {
>         if (myptr->flags & SKBMOD_F_DMAC)
>                  ether_addr_copy(eth_hdr(skb)->h_dest, myptr->eth_dst);
>          if (myptr->flags & SKBMOD_F_SMAC)
>                  ether_addr_copy(eth_hdr(skb)->h_source, myptr->eth_src);
>          if (myptr->flags & SKBMOD_F_ETYPE)
>                  eth_hdr(skb)->h_proto = myptr->eth_type;
> }
> rcu_read_unlock();

Thanks Eric.
This is the approach i thought Cong was going to take but in a way that
it applies to all actions.
It requires I do this extra allocation per update/create - I am not sure 
how much of a big deal that is (we take pride in our update rate).
Let me work and post something simple that captures these ideas
then wait to see what Cong has in mind for the general approach.

cheers,
jamal
