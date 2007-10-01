From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 06/10] Make qdisc changeable.
Date: Mon, 01 Oct 2007 13:47:10 -0700
Message-ID: <47015CCE.40204@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199772562-git-send-email-bugfood-ml@fatooh.org> <4700F980.3000701@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List /s <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:41630 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753029AbXJAUrR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 16:47:17 -0400
In-Reply-To: <4700F980.3000701@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> Re-implement sfq_change() and enable Qdisc_opts.change so "tc qdisc
>> change" will work.
>>
> 
>> +static int sfq_change(struct Qdisc *sch, struct rtattr *opt)
>> +{
>> +	...
>> +
>> +	/* finish up */
>> +	if (q->perturb_period) {
>> +		q->perturb_timer.expires = jiffies + q->perturb_period;
>> +		add_timer(&q->perturb_timer);
>> +	} else {
>> +		q->perturbation = 0;
> 
> 
> Seems counter-productive to explicitly set it to zero since
> it was still used during tranfering the packets with the
> old value. So I'd suggest to remove this or alternatively
> set it to the final value *before* transfering the packets.

I suppose so; you're right. I'll adapt that part to fit before 
transferring the packets.

-Corey
