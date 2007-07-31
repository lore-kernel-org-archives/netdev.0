From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 6/7] Make qdisc changeable.
Date: Tue, 31 Jul 2007 00:43:49 -0700
Message-ID: <46AEE835.8060509@fatooh.org>
References: <11857548771998-git-send-email-bugfood-ml@fatooh.org> <11857548783311-git-send-email-bugfood-ml@fatooh.org> <46ADF18A.4060008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:55499 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751716AbXGaHnp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Jul 2007 03:43:45 -0400
In-Reply-To: <46ADF18A.4060008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> Re-implement sfq_change() and enable Qdisc_opts.change so "tc qdisc
>> change" will work.
>>
>> Signed-off-by: Corey Hickey <bugfood-ml@fatooh.org>
>> ---
>>  net/sched/sch_sfq.c |   51 ++++++++++++++++++++++++++++++++++++++++++++++++++-
>>  1 files changed, 50 insertions(+), 1 deletions(-)
>>
>> diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
>> index e6a6a21..e042cd0 100644
>> --- a/net/sched/sch_sfq.c
>> +++ b/net/sched/sch_sfq.c
>> @@ -485,6 +485,55 @@ static int sfq_init(struct Qdisc *sch, struct rtattr *opt)
>>  	return 0;
>>  }
>>  
>> +static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
>> +{
>> +	struct sfq_sched_data *q = qdisc_priv(sch);
>> +	struct sfq_sched_data tmp;
>> +	struct sk_buff *skb;
>> +	int err;
>> +	
>> +	/* set up tmp queue */
>> +	memset(&tmp, 0, sizeof(struct sfq_sched_data));
>> +	tmp.quantum = psched_mtu(sch->dev); /* default */
> 
> 
> If no value is given it should use the old value instead of
> reinitializing to the default.
> 
>> +	if ((err = sfq_q_init(&tmp, opt)))
>> +		return err;
> 
> 
> This will also use defaults for all unspecified values. It would
> be more consistent with other qdiscs to only change those values
> that are actually specified, so something like "tc qdisc change ...
> perturb 10" will *only* change the perturbation parameter.

I somehow had it in my head that a qdisc change was supposed to work 
that way. I'll change my patch.

> I'm not sure reusing the initialization function and copying the
> parameters is the best way to do this.

I'm not sure either, but I do like that it's conceptually simple and it 
keeps the parameter handling in one place. I've thought and stared for a 
while, and I don't see a better way, but that could of course be due to 
my limited understanding and general newbiehood in that regard.

Thanks again for the review. I'll try to get a new batch of patches sent 
off tomorrow.

-Corey
