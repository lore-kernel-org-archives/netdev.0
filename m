From: "Tobias Koeck" <tobias.koeck@gmail.com>
Subject: can I use the icmp_reply function (/net/ipv4/icmp.c) for creating an icmp query request?
Date: Thu, 17 Jul 2008 01:57:39 +0200
Message-ID: <379e30200807161657h623b47cbv28f97e37b239a852@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: john.tormento@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:2599 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbYGPX5m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 19:57:42 -0400
Received: by fg-out-1718.google.com with SMTP id 19so2528902fgg.17
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2008 16:57:39 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm writing on an experimental icmp-query function and need to know If
i can use the icmp_reply function (/net/ipv4/icmp.c) for creating an
icmp query request?

The icmp_send function is after reading the source code only for error
icmp packets. The name icmp_reply implies it's only for query replies?

Greetings and thanks
Tobias

2008/7/17 Jussi Kivilinna <jussi.kivilinna@mbnet.fi>:
> Quoting "Patrick McHardy" <kaber@trash.net>:
>
>> Jussi Kivilinna wrote:
>>>
>>> Quoting "Patrick McHardy" <kaber@trash.net>:
>>>
>>>>
>>>> I thought you were going to make this a generic qdisc feature.
>>>> Why is configuration still qdisc specific?
>>>>
>>>
>>> I was thinking keeping scope of this patch within hfsc, as done  with
>>> rest of rate table qdiscs. So it would be better to have they  all to use
>>> generic size table instead of duplicating rtab code.
>>
>> Well, to use this feature consistently (meaning sizes propagate
>> down to inner qdiscs) it needs to be a generic feature.
>>
>>>> I was thinking of something like this:
>>>>
>>>> - add generic attributes for configuring size tables for any
>>>>  qdisc, handle those in sch_api
>>>>
>>>> - add qdisc_enqueue() wrapper that calculates the size and
>>>>  stores it in skb->cb, convert direct calls of sch->enqueue
>>>>  to use it
>>>>
>>>> - change direct uses of skb->len to use the size from the cb
>>>>
>>>> The second step might need a bit more thought to make sure
>>>> qdiscs don't get confused when the dequeued packet is larger
>>>> than the enqueued one, but I think they usually don't care.
>>>>
>>>
>>> I guess I'll start over using your size table patch as base then.
>>
>> I'm not sure that part is correct in my patch :)
>>
>
> Here's first version of generic size table feature. Didn't get chance to
> test too much yet but hfsc&sfq seems to be ok.
>
>  - Jussi
>
