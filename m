From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 01/10] Preparatory refactoring part 1.
Date: Mon, 01 Oct 2007 13:46:44 -0700
Message-ID: <47015CB4.7000102@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199771607-git-send-email-bugfood-ml@fatooh.org> <4700F54A.6070408@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:41569 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752735AbXJAUqv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 16:46:51 -0400
In-Reply-To: <4700F54A.6070408@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> Make a new function sfq_q_enqueue() that operates directly on the
>> queue data. This will be useful for implementing sfq_change() in
>> a later patch. A pleasant side-effect is reducing most of the
>> duplicate code in sfq_enqueue() and sfq_requeue().
>>
>> Similarly, make a new function sfq_q_dequeue().
>>
>> Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
>> ---
>>  net/sched/sch_sfq.c |   72 +++++++++++++++++++++++++++------------------------
>>  1 files changed, 38 insertions(+), 34 deletions(-)
>>
>> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
>> index 3a23e30..57485ef 100644
>> --- a/net/sched/sch_sfq.c
>> +++ b/net/sched/sch_sfq.c
>>
> 
> 
> The sfq_q_enqueue part looks fine.
> 
>>  
>> -	sch->qstats.drops++;
> 
> 
> A line in the changelog explaining that this was increased twice
> would have been nice.

Certainly; I think I didn't realize, when you originally pointed out the 
duplicate incrementing, that it was a bug in the original version and 
not in my patch. Otherwise, I would have sent it as a separate patch.

If a note in this patch will suffice, though, I'll definitely do so.

>>  	sfq_drop(sch);
>>  	return NET_XMIT_CN;
>>  }
>>  
>> -
>> -
>> -
>> -static struct sk_buff *
>> -sfq_dequeue(struct Qdisc* sch)
>> +static struct
>> +sk_buff *sfq_q_dequeue(struct sfq_sched_data *q)
> 
> 
> What is this function needed for?

It gets used in sfq_change for moving packets from the old queue into 
the new one. In this case, we don't want to modify sch->q.qlen or 
sch->qstats.backlog, since those don't actually change.

          while ((skb = sfq_q_dequeue(q)) != NULL)
                  sfq_q_enqueue(skb, &tmp, SFQ_TAIL);


I'll improve the description of this patch to make that more clear.

-Corey
