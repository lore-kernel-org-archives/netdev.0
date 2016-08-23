From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 04/15] net: sched: provide per cpu qstat helpers
Date: Tue, 23 Aug 2016 16:50:54 -0700
Message-ID: <57BCE15E.6040303@gmail.com>
References: <20160823202135.14368.62466.stgit@john-Precision-Tower-5810>
 <20160823202412.14368.48361.stgit@john-Precision-Tower-5810>
 <1471994713.14381.63.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, davem@davemloft.net, brouer@redhat.com,
        xiyou.wangcong@gmail.com, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f68.google.com ([209.85.220.68]:36436 "EHLO
        mail-pa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753946AbcHXAGW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 20:06:22 -0400
Received: by mail-pa0-f68.google.com with SMTP id ez1so46764pab.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 17:05:36 -0700 (PDT)
In-Reply-To: <1471994713.14381.63.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-23 04:25 PM, Eric Dumazet wrote:
> On Tue, 2016-08-23 at 13:24 -0700, John Fastabend wrote:
>> The per cpu qstats support was added with per cpu bstat support which
>> is currently used by the ingress qdisc. This patch adds a set of
>> helpers needed to make other qdiscs that use qstats per cpu as well.
>>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>  include/net/sch_generic.h |   39 +++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 39 insertions(+)
>>
>> diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
>> index 3de6a8c..f1b8268 100644
>> --- a/include/net/sch_generic.h
>> +++ b/include/net/sch_generic.h
>> @@ -565,12 +565,43 @@ static inline void qdisc_qstats_backlog_dec(struct Qdisc *sch,
>>  	sch->qstats.backlog -= qdisc_pkt_len(skb);
>>  }
>>  
>> +static inline void qdisc_qstats_cpu_backlog_dec(struct Qdisc *sch,
>> +						const struct sk_buff *skb)
>> +{
>> +	struct gnet_stats_queue *q = this_cpu_ptr(sch->cpu_qstats);
>> +
>> +	q->backlog -= qdisc_pkt_len(skb);
> 
> Probably could use 
> 	this_cpu_sub(sch->cpu_qstats->backlog, qdisc_pkt_len(skb))
> 
> 

Sure, should probably create a patch to do the same for some existing
cases matching this pattern as well then.
