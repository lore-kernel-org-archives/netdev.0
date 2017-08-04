From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2] net ipv6: convert fib6_table rwlock to a
 percpu lock
Date: Fri, 04 Aug 2017 10:51:14 -0700 (PDT)
Message-ID: <20170804.105114.438539102203155666.davem@davemloft.net>
References: <2dcefcf7e75a5c242a20d7904096be91addbfba7.1501864467.git.shli@fb.com>
        <1501866461.25002.41.camel@edumazet-glaptop3.roam.corp.google.com>
        <a297a638-83e6-41bf-e803-9a3fd158ad00@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shli@kernel.org, netdev@vger.kernel.org,
        Kernel-team@fb.com, shli@fb.com, weiwan@google.com,
        stephen@networkplumber.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36778 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751271AbdHDRvS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 13:51:18 -0400
In-Reply-To: <a297a638-83e6-41bf-e803-9a3fd158ad00@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Fri, 4 Aug 2017 11:11:40 -0600

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

Me too.
