From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 09/10] Change perturb_period to unsigned.
Date: Mon, 01 Oct 2007 13:47:16 -0700
Message-ID: <47015CD4.2040302@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199784097-git-send-email-bugfood-ml@fatooh.org> <4700FA02.8090800@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:41641 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753082AbXJAUrX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 16:47:23 -0400
In-Reply-To: <4700FA02.8090800@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> perturb_period is currently a signed integer, but I can't see any good
>> reason why this is so--a negative perturbation period will add a timer
>> that expires in the past, causing constant perturbation, which makes
>> hashing useless.
>>
>> 	if (q->perturb_period) {
>> 		q->perturb_timer.expires = jiffies + q->perturb_period;
>> 		add_timer(&q->perturb_timer);
>> 	}
>>
>> Strictly speaking, this will break binary compatibility with older
>> versions of tc, but that ought not to be a problem because (a) there's
>> no valid use for a negative perturb_period, and (b) negative values
>> will be seen as high values (> INT_MAX), which don't work anyway.
>>
>> If perturb_period is too large, (perturb_period * HZ) will overflow the
>> size of an unsigned int and wrap around. So, check for thet and reject
>> values that are too high.
> 
> 
> Sounds reasonable.
> 
>> --- a/net/sched/sch_sfq.c
>> +++ b/net/sched/sch_sfq.c
>> @@ -74,6 +74,9 @@
>>  typedef unsigned int sfq_index;
>>  #define SFQ_MAX_DEPTH (UINT_MAX / 2 - 1)
>>  
>> +/* We don't want perturb_period * HZ to overflow an unsigned int. */
>> +#define SFQ_MAX_PERTURB (UINT_MAX / HZ)
> 
> 
> jiffies are unsigned long.

Hmm. You're right. It looks like my previous patch obviated the need for 
this part. I'll remove it.

-Corey
