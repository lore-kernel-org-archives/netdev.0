From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 02/15] net: rcu-ify tcf_proto
Date: Tue, 02 Sep 2014 13:52:18 -0700 (PDT)
Message-ID: <20140902.135218.623659943093020151.davem@davemloft.net>
References: <20140825004830.2180.70308.stgit@nitbit.x32>
	<20140824.223133.170922940598584254.davem@davemloft.net>
	<54051FC1.6030106@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com,
	brouer@redhat.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58437 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754164AbaIBUwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:52:19 -0400
In-Reply-To: <54051FC1.6030106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 01 Sep 2014 18:39:13 -0700

> On 08/24/2014 10:31 PM, David Miller wrote:
>> From: John Fastabend <john.fastabend@gmail.com>
>> Date: Sun, 24 Aug 2014 17:48:31 -0700
>>
>>> @@ -722,8 +724,9 @@ static void sfq_free(void *addr)
>>>   static void sfq_destroy(struct Qdisc *sch)
>>>   {
>>>   	struct sfq_sched_data *q = qdisc_priv(sch);
>>> +	struct tcf_proto *fl = rtnl_dereference(q->filter_list);
>>>
>>> -	tcf_destroy_chain(&q->filter_list);
>>> +	tcf_destroy_chain(&fl);
> 
> Sorry for the delayed reply...
> 
>>
>> This will cause tcf_destroy_chain() to set the local variable
>> 'fl' to NULL rather than q->filter_list.
>>
>> I don't see how this can be correct at all.
> 
> Right now (without these patches) nothing sets q->filter_list
> to NULL and we only call this when the qdisc is being destroyed.

Yes, it does set it to NULL, by virtue of how the loop iterates.

It iterates by setting the "*fl" to tp->next until that evaluates to
NULL.  Thereby setting *fl to NULL.

So the old code would set ->filter_list to NULL, your code will not.
