From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 08/13] net: sched: support skb_bad_tx with lockless
 qdisc
Date: Wed, 17 Aug 2016 16:00:51 -0700
Message-ID: <57B4ECA3.7000208@gmail.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
 <20160817193646.27032.75592.stgit@john-Precision-Tower-5810>
 <1471474686.29842.53.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, brouer@redhat.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:34715 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbcHQXBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:01:07 -0400
Received: by mail-pa0-f66.google.com with SMTP id hh10so211059pac.1
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 16:01:06 -0700 (PDT)
In-Reply-To: <1471474686.29842.53.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-17 03:58 PM, Eric Dumazet wrote:
> On Wed, 2016-08-17 at 12:36 -0700, John Fastabend wrote:
>> Similar to how gso is handled skb_bad_tx needs to be per cpu to handle
>> lockless qdisc with multiple writer/producers.
> \
>> @@ -1021,6 +1026,7 @@ err_out4:
>>  	free_percpu(sch->cpu_bstats);
>>  	free_percpu(sch->cpu_qstats);
>>  	free_percpu(sch->gso_cpu_skb);
>> +	free_percpu(sch->skb_bad_txq_cpu);
> 
> 
> This might be the time to group all these per cpu allocations to a
> single one, to help data locality and decrease overhead of having XX
> pointers.
> 
> 
> 

Sounds like a good idea to me. I'll go ahead and add a patch to the
front to consolidate the stats and then add these there.
