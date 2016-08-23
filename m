From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 08/13] net: sched: support skb_bad_tx with lockless
 qdisc
Date: Tue, 23 Aug 2016 13:11:21 -0700
Message-ID: <57BCADE9.5070004@gmail.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
 <20160817193646.27032.75592.stgit@john-Precision-Tower-5810>
 <1471474686.29842.53.camel@edumazet-glaptop3.roam.corp.google.com>
 <57B4ECA3.7000208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
        alexei.starovoitov@gmail.com, brouer@redhat.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:36603 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753471AbcHWUM3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 16:12:29 -0400
Received: by mail-pa0-f65.google.com with SMTP id ez1so10410250pab.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 13:11:37 -0700 (PDT)
In-Reply-To: <57B4ECA3.7000208@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-17 04:00 PM, John Fastabend wrote:
> On 16-08-17 03:58 PM, Eric Dumazet wrote:
>> On Wed, 2016-08-17 at 12:36 -0700, John Fastabend wrote:
>>> Similar to how gso is handled skb_bad_tx needs to be per cpu to handle
>>> lockless qdisc with multiple writer/producers.
>> \
>>> @@ -1021,6 +1026,7 @@ err_out4:
>>>  	free_percpu(sch->cpu_bstats);
>>>  	free_percpu(sch->cpu_qstats);
>>>  	free_percpu(sch->gso_cpu_skb);
>>> +	free_percpu(sch->skb_bad_txq_cpu);
>>
>>
>> This might be the time to group all these per cpu allocations to a
>> single one, to help data locality and decrease overhead of having XX
>> pointers.
>>
>>
>>
> 
> Sounds like a good idea to me. I'll go ahead and add a patch to the
> front to consolidate the stats and then add these there.
> 

Actually this turned out to be not so trivial. To do it reasonably
requires changes in how gnet stats work and such. I'm going to propose
pushing this into a series after the initial lockless set otherwise the
patch set is going to start pushing 20+ patches.

Also a follow on series to make all the qdiscs support per cpu stats
would be nice and allows us to remove a lot of the annoying if/else
cases around stats. Its a bit tedious to go and change all the qdiscs
but mostly mechanical.

.John
