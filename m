From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next v2 1/3] net_sched: tbf: support of 64bit rates
Date: Fri, 8 Nov 2013 09:40:47 +0800
Message-ID: <527C411F.80307@huawei.com>
References: <1383790412-41944-1-git-send-email-yangyingliang@huawei.com> <1383790412-41944-2-git-send-email-yangyingliang@huawei.com> <527BA2E3.5090905@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:4117 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753320Ab3KHBlN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 20:41:13 -0500
In-Reply-To: <527BA2E3.5090905@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/7 22:25, Sergei Shtylyov wrote:
> Hello.
> 
> On 07-11-2013 6:13, Yang Yingliang wrote:
> 
>> With psched_ratecfg_precompute(), tbf can deal with 64bit rates.
>> Add two new attributes so that tc can use them to break the 32bit
>> limit.
> 
>> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>
> [...]
> 
>> diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
>> index b057122..b736517 100644
>> --- a/net/sched/sch_tbf.c
>> +++ b/net/sched/sch_tbf.c
> [...]
>> @@ -402,6 +409,13 @@ static int tbf_dump(struct Qdisc *sch, struct sk_buff *skb)
>>       opt.buffer = PSCHED_NS2TICKS(q->buffer);
>>       if (nla_put(skb, TCA_TBF_PARMS, sizeof(opt), &opt))
>>           goto nla_put_failure;
>> +    if ((q->rate.rate_bytes_ps >= (1ULL << 32)) &&
>> +            nla_put_u64(skb, TCA_TBF_RATE64, q->rate.rate_bytes_ps))
>> +        goto nla_put_failure;
>> +    if (q->peak_present &&
>> +            (q->peak.rate_bytes_ps >= (1ULL << 32)) &&
>> +            nla_put_u64(skb, TCA_TBF_PRATE64, q->peak.rate_bytes_ps))
>> +        goto nla_put_failure;
> 
>    According to the networking coding style, the *if* continuation lines should start under the next character after (.
> 
> WBR, Sergei

Got it, i'll fix in next patch.
Thanks

> 
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
