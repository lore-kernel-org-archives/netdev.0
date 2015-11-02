From: Cong Wang <cwang@twopensource.com>
Subject: Re: [Patch net-next v2 2/4] net_sched: update hierarchical backlog too
Date: Mon, 2 Nov 2015 13:09:30 -0800
Message-ID: <CAHA+R7NkU3Bme5MbgFraOo=7SRYUF+F-6owyzFxfVidjc2AxMw@mail.gmail.com>
References: <1446229351-13412-1-git-send-email-xiyou.wangcong@gmail.com>
	<1446229351-13412-3-git-send-email-xiyou.wangcong@gmail.com>
	<1446233450.6254.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f171.google.com ([209.85.160.171]:36845 "EHLO
	mail-yk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbbKBVJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2015 16:09:30 -0500
Received: by ykba4 with SMTP id a4so152504485ykb.3
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 13:09:30 -0800 (PST)
In-Reply-To: <1446233450.6254.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Sorry for the delay)

On Fri, Oct 30, 2015 at 12:30 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2015-10-30 at 11:22 -0700, Cong Wang wrote:
>> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
>> index 3abab53..498f0a2 100644
>> --- a/net/sched/sch_sfq.c
>> +++ b/net/sched/sch_sfq.c
>> @@ -346,7 +346,7 @@ static int
>>  sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>  {
>>       struct sfq_sched_data *q = qdisc_priv(sch);
>> -     unsigned int hash;
>> +     unsigned int hash, dropped;
>>       sfq_index x, qlen;
>>       struct sfq_slot *slot;
>>       int uninitialized_var(ret);
>> @@ -461,7 +461,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>               return NET_XMIT_SUCCESS;
>>
>>       qlen = slot->qlen;
>> -     sfq_drop(sch);
>> +     dropped = sfq_drop(sch);
>>       /* Return Congestion Notification only if we dropped a packet
>>        * from this flow.
>>        */
>> @@ -469,7 +469,7 @@ sfq_enqueue(struct sk_buff *skb, struct Qdisc *sch)
>>               return NET_XMIT_CN;
>
>
> I believe you missed the NET_XMIT_CN cases.
>
> SFQ can drop a prior packet, and queue current packet.
>
> qdisc_tree_reduce_backlog() wont be called to update parents.
>
> Not sure about other qdisc(s)

Are you saying some qdisc_tree_reduce_backlog() is missing? It could be,
since I don't audit that, if so, I'd do that in a separated patch, because this
patch is supposed to fix existing qdisc_tree_reduce_backlog().

Does this make sense for you?

Thanks.
