From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH net-next-2.6 v4 2/2] hfsc: add link layer overhead	adaption
Date: Tue, 15 Jul 2008 12:55:25 +0200
Message-ID: <487C821D.1010806@trash.net>
References: <20080710193434.19525.83454.stgit@fate.lan>	<20080710193440.19525.93085.stgit@fate.lan> <487B61A9.5090204@trash.net> <20080715135244.17106mgc64fxlpj4@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54148 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756861AbYGOKz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 06:55:27 -0400
In-Reply-To: <20080715135244.17106mgc64fxlpj4@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jussi Kivilinna wrote:
> Quoting "Patrick McHardy" <kaber@trash.net>:
> 
>>
>> I thought you were going to make this a generic qdisc feature.
>> Why is configuration still qdisc specific?
>>
> 
> I was thinking keeping scope of this patch within hfsc, as done with 
> rest of rate table qdiscs. So it would be better to have they all to use 
> generic size table instead of duplicating rtab code.

Well, to use this feature consistently (meaning sizes propagate
down to inner qdiscs) it needs to be a generic feature.

>> I was thinking of something like this:
>>
>> - add generic attributes for configuring size tables for any
>>   qdisc, handle those in sch_api
>>
>> - add qdisc_enqueue() wrapper that calculates the size and
>>   stores it in skb->cb, convert direct calls of sch->enqueue
>>   to use it
>>
>> - change direct uses of skb->len to use the size from the cb
>>
>> The second step might need a bit more thought to make sure
>> qdiscs don't get confused when the dequeued packet is larger
>> than the enqueued one, but I think they usually don't care.
>>
> 
> I guess I'll start over using your size table patch as base then.

I'm not sure that part is correct in my patch :)
