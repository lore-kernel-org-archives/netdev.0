From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 10/13] net: sched: lockless support for netif_schedule
Date: Wed, 17 Aug 2016 16:17:13 -0700
Message-ID: <57B4F079.5070109@gmail.com>
References: <20160817193120.27032.20918.stgit@john-Precision-Tower-5810>
 <20160817193738.27032.25592.stgit@john-Precision-Tower-5810>
 <1471474877.29842.54.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, brouer@redhat.com,
	john.r.fastabend@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:32894 "EHLO
	mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752865AbcHQXR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 19:17:26 -0400
Received: by mail-pa0-f68.google.com with SMTP id vy10so240990pac.0
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 16:17:26 -0700 (PDT)
In-Reply-To: <1471474877.29842.54.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-17 04:01 PM, Eric Dumazet wrote:
> On Wed, 2016-08-17 at 12:37 -0700, John Fastabend wrote:
> 
>> diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
>> index d10b762..f5b7254 100644
>> --- a/net/sched/sch_generic.c
>> +++ b/net/sched/sch_generic.c
>> @@ -171,6 +171,7 @@ static void try_bulk_dequeue_skb_slow(struct Qdisc *q,
>>  			if (qdisc_is_percpu_stats(q)) {
>>  				qdisc_qstats_cpu_backlog_inc(q, nskb);
>>  				qdisc_qstats_cpu_qlen_inc(q);
>> +				set_thread_flag(TIF_NEED_RESCHED);
>>  			} else {
>>  				qdisc_qstats_backlog_inc(q, nskb);
>>  				q->q.qlen++;
> 
> Hmm... care to elaborate this bit ?
> 
> 
> 

ah dang thats leftover from trying to resolve a skb getting stuck on the
bad_txq_cell from qdisc_enqueue_skb_bad_txq(). You'll notice I added
a __netif_schedule(skb) call in qdisc_enqueue_skb_bad_txq() which
resolves this and the set_thread_flag() here can then just be removed.

.John
