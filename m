From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next v2 2/3] net_sched: fix some checkpatch errors
Date: Fri, 8 Nov 2013 09:51:19 +0800
Message-ID: <527C4397.5010803@huawei.com>
References: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com> <1383790412-41944-3-git-send-email-yangyingliang@huawei.com> <527BA4C4.50704@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:12245 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752511Ab3KHBvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 20:51:47 -0500
In-Reply-To: <527BA4C4.50704@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/7 22:33, Sergei Shtylyov wrote:
> Hello.
> 
> On 07-11-2013 6:13, Yang Yingliang wrote:
> 
>> There are some checkpatch errors, fix them.
> 
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
>> Suggested-by: Stephen Hemminger <stephen@networkplumber.org>
> [...]
> 
>> diff --git a/net/sched/act_api.c b/net/sched/act_api.c
>> index fd70728..d92a90e9 100644
>> --- a/net/sched/act_api.c
>> +++ b/net/sched/act_api.c
>> @@ -191,7 +191,8 @@ u32 tcf_hash_new_index(u32 *idx_gen, struct tcf_hashinfo *hinfo)
>>               val = 1;
>>       } while (tcf_hash_lookup(val, hinfo));
>>
>> -    return (*idx_gen = val);
>> +    *idx_gen = val;
>> +    return *idx_gen;
> 
>     return val;
> 
> would have been simpler.

Yeah, i think so.
Thanks

> 
>> diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
>> index 7a42c81..a8f40f5 100644
>> --- a/net/sched/sch_cbq.c
>> +++ b/net/sched/sch_cbq.c
>> @@ -1058,7 +1058,8 @@ static void cbq_normalize_quanta(struct cbq_sched_data *q, int prio)
>>                   cl->quantum = (cl->weight*cl->allot*q->nclasses[prio])/
>>                       q->quanta[prio];
>>               }
>> -            if (cl->quantum <= 0 || cl->quantum>32*qdisc_dev(cl->qdisc)->mtu) {
>> +            if (cl->quantum <= 0 ||
>> +                cl->quantum > 32*qdisc_dev(cl->qdisc)->mtu) {
> 
>    According to the networking coding style, the continuation line should start right under 'cl' on the first line of *if*. The way you did it makes it harder for the eyes to differentiate the code in the *if* branch from the *if* expression.
> 
>>                   pr_warning("CBQ: class %08x has bad quantum==%ld, repaired.\n",
>>                          cl->common.classid, cl->quantum);
>>                   cl->quantum = qdisc_dev(cl->qdisc)->mtu/2 + 1;
> [...]
> 
> WBR, Sergei
> 
> 
> 
