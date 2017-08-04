From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net-next V2] net ipv6: convert fib6_table rwlock to a
 percpu lock
Date: Fri, 4 Aug 2017 10:20:05 -0700
Message-ID: <CAEA6p_D99W+Qt3SuJ2ADZspHJxtevOXGEVoce=jTBDgkgKg8Ew@mail.gmail.com>
References: <2dcefcf7e75a5c242a20d7904096be91addbfba7.1501864467.git.shli@fb.com>
 <1501866461.25002.41.camel@edumazet-glaptop3.roam.corp.google.com> <a297a638-83e6-41bf-e803-9a3fd158ad00@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>, Kernel-team@fb.com,
        Shaohua Li <shli@fb.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: David Ahern <dsahern@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Shaohua Li <shli@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:38052 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752608AbdHDRUG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 13:20:06 -0400
Received: by mail-ua0-f179.google.com with SMTP id w45so9893107uac.5
        for <netdev@vger.kernel.org>; Fri, 04 Aug 2017 10:20:06 -0700 (PDT)
In-Reply-To: <a297a638-83e6-41bf-e803-9a3fd158ad00@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 4, 2017 at 10:11 AM, David Ahern <dsahern@gmail.com> wrote:
> On 8/4/17 11:07 AM, Eric Dumazet wrote:
>> On Fri, 2017-08-04 at 09:38 -0700, Shaohua Li wrote:
>>> From: Shaohua Li <shli@fb.com>
>>>
>>> In a syn flooding test, the fib6_table rwlock is a significant
>>> bottleneck. While converting the rwlock to rcu sounds straighforward,
>>> but is very challenging if it's possible. A percpu spinlock (lglock has
>>> been removed from kernel, so I added a simple implementation here) is
>>> quite trival for this problem since updating the routing table is a rare
>>> event. In my test, the server receives around 1.5 Mpps in syn flooding
>>> test without the patch in a dual sockets and 56-CPU system. With the
>>> patch, the server receives around 3.8Mpps, and perf report doesn't show
>>> the locking issue.
>>>
>>> Of course the percpu lock isn't as good as rcu, so this isn't intended
>>> to replace rcu, but this is much better than current readwrite lock.
>>> Before we have a rcu implementation, this is a good temporary solution.
>>> Plus, this is a trival change, there is nothing to prevent pursuing a
>>> rcu implmentation.
>>>
>>> Cc: Wei Wang <weiwan@google.com>
>>> Cc: Eric Dumazet <eric.dumazet@gmail.com>
>>> Cc: Stephen Hemminger <stephen@networkplumber.org>
>>> Signed-off-by: Shaohua Li <shli@fb.com>
>>> ---
>>
>> Wei has almost done the RCU conversion.
>>
>> This patch is probably coming too late.
>
>
> +1
>
> I'd rather see the RCU conversion than a move to per-cpu locks.

I am actively working on the RCU conversion.
The main coding part is mostly done and I am working on testing it.
Some more time is needed to catch the rest of the missing pieces and
get the patches ready.

Thanks.
Wei
