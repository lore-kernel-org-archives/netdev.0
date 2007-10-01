From: Corey Hickey <bugfood-ml@fatooh.org>
Subject: Re: [PATCH 10/10] Use nested compat attributes to pass parameters.
Date: Mon, 01 Oct 2007 13:47:22 -0700
Message-ID: <47015CDA.60109@fatooh.org>
References: <1191019977201-git-send-email-bugfood-ml@fatooh.org> <11910199782593-git-send-email-bugfood-ml@fatooh.org> <4700FC1E.9040309@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hot.fatooh.org ([208.78.103.127]:41659 "EHLO hot.fatooh.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753103AbXJAUr2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2007 16:47:28 -0400
In-Reply-To: <4700FC1E.9040309@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Corey Hickey wrote:
>> +
>> +#define GET_PARAM(dst, nest, compat) do { \
>> +	struct rtattr *rta = tb[(nest) - 1]; \
>> +	if (rta) \
>> +		(dst) = RTA_GET_U32(rta); \
>> +	else if ((compat)) \
>> +		(dst) = (compat); \
>> +} while (0)
> 
> 
> An inline function and a comment why this is done would increase
> readability.

Well, I had a reason for making a macro, but it probably wasn't a good 
reason. Looking now, I don't see why not to make a function. I'll see 
what I can do.

>> +	nest = RTA_NEST_COMPAT(skb, TCA_OPTIONS, sizeof(opt), &opt);
>> +
>> +	RTA_PUT_U32(skb, TCA_SFQ_QUANTUM, q->quantum);
>> +	RTA_PUT_U32(skb, TCA_SFQ_PERTURB, q->perturb_period);
>> +	RTA_PUT_U32(skb, TCA_SFQ_LIMIT,   q->limit);
>> +	RTA_PUT_U32(skb, TCA_SFQ_DIVISOR, q->hash_divisor);
>> +	RTA_PUT_U32(skb, TCA_SFQ_FLOWS,   q->depth);
>>  	RTA_PUT(skb, TCA_OPTIONS, sizeof(opt), &opt);
> 
> 
> This is wrong, RTA_NEST_COMPAT already dumps the structure.

You mean that last line (RTA_PUT) is superfluous, right? I can't see a 
reason for it to be there, so I must have just forgotten to delete it 
from the original code.

If I'm wrong, I might need a little hand-holding here. My understanding 
of all the RTA stuff is a bit shaky.


Much thanks for the review. I'll make a new set of patches soon.

-Corey
