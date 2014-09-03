From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v2 02/15] net: rcu-ify tcf_proto
Date: Tue, 02 Sep 2014 23:23:23 -0700
Message-ID: <5406B3DB.8010505@gmail.com>
References: <20140825004830.2180.70308.stgit@nitbit.x32> <20140824.223133.170922940598584254.davem@davemloft.net> <54051FC1.6030106@gmail.com> <20140902.135218.623659943093020151.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:50351 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbaICGXj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 02:23:39 -0400
Received: by mail-ob0-f170.google.com with SMTP id m8so5729651obr.15
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 23:23:39 -0700 (PDT)
In-Reply-To: <20140902.135218.623659943093020151.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2014 01:52 PM, David Miller wrote:
> From: John Fastabend <john.fastabend@gmail.com>
> Date: Mon, 01 Sep 2014 18:39:13 -0700
>
>> On 08/24/2014 10:31 PM, David Miller wrote:
>>> From: John Fastabend <john.fastabend@gmail.com>
>>> Date: Sun, 24 Aug 2014 17:48:31 -0700
>>>
>>>> @@ -722,8 +724,9 @@ static void sfq_free(void *addr)
>>>>    static void sfq_destroy(struct Qdisc *sch)
>>>>    {
>>>>    	struct sfq_sched_data *q = qdisc_priv(sch);
>>>> +	struct tcf_proto *fl = rtnl_dereference(q->filter_list);
>>>>
>>>> -	tcf_destroy_chain(&q->filter_list);
>>>> +	tcf_destroy_chain(&fl);
>>
>> Sorry for the delayed reply...
>>
>>>
>>> This will cause tcf_destroy_chain() to set the local variable
>>> 'fl' to NULL rather than q->filter_list.
>>>
>>> I don't see how this can be correct at all.
>>
>> Right now (without these patches) nothing sets q->filter_list
>> to NULL and we only call this when the qdisc is being destroyed.
>
> Yes, it does set it to NULL, by virtue of how the loop iterates.
>

yes of course its obvious now that you spell it out for me.

> It iterates by setting the "*fl" to tp->next until that evaluates to
> NULL.  Thereby setting *fl to NULL.
>
> So the old code would set ->filter_list to NULL, your code will not.
>

right I will fix this in the morning along with the sparse
warnings related to the tcf_find signatures.

Thanks
John


-- 
John Fastabend         Intel Corporation
