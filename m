From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next] net_sched: increase drops and decrease backlog
 when packets are dropped
Date: Thu, 8 May 2014 10:08:15 +0800
Message-ID: <536AE70F.7060307@huawei.com>
References: <1399369056-1632-1-git-send-email-yangyingliang@huawei.com> <1399384701.15399.4.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <vtlam@google.com>,
	<nanditad@google.com>, <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:27816 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506AbaEHCIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 22:08:21 -0400
In-Reply-To: <1399384701.15399.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/5/6 21:58, Eric Dumazet wrote:
> On Tue, 2014-05-06 at 17:37 +0800, Yang Yingliang wrote:
>> When packets are dropped, backlog and drops statistic of qdisc
>> need be changed. Replace kfree_skb() with qdisc_drop() for
>> increasing drops.
>>
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> ---
> 
> 
>> diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
>> index 0bf432c782c1..83abd4cd10cd 100644
>> --- a/net/sched/sch_fq_codel.c
>> +++ b/net/sched/sch_fq_codel.c
>> @@ -344,7 +344,8 @@ static int fq_codel_change(struct Qdisc *sch, struct nlattr *opt)
>>  	while (sch->q.qlen > sch->limit) {
>>  		struct sk_buff *skb = fq_codel_dequeue(sch);
>>  
>> -		kfree_skb(skb);
>> +		sch->qstats.backlog -= qdisc_pkt_len(skb);
> 
> Hmmm... please describe how you tested this change ?

Compiled only. The packet is dropped, so I think the backlog should be decreased.

Regards,
Yang

> 
>> +		qdisc_drop(skb, sch);
>>  		q->cstats.drop_count++;
>>  	}
>>  	qdisc_tree_decrease_qlen(sch, q->cstats.drop_count);
> 
> 
> 
> 
