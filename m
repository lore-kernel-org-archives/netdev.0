From: Ferry Huberts <mailings@hupie.com>
Subject: Re: [PATCH 2/2] net: netem: always adjust now/delay when not reordering
Date: Fri, 23 Aug 2013 14:50:27 +0200
Message-ID: <52175A93.8020506@hupie.com>
References: <1377011469-26151-1-git-send-email-mailings@hupie.com>  <1377011469-26151-2-git-send-email-mailings@hupie.com>  <5214D9F2.90900@stusta.de> <1377099575.4226.120.camel@edumazet-glaptop> <5214E774.8060400@hupie.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Johannes Naab <jn@stusta.de>, netdev@vger.kernel.org,
	hagen@jauu.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hupie.dyndns.org ([80.101.237.101]:40567 "EHLO hupie.dyndns.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251Ab3HWMu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Aug 2013 08:50:28 -0400
In-Reply-To: <5214E774.8060400@hupie.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 21/08/13 18:14, Ferry Huberts wrote:
> 
> 
> On 21/08/13 17:39, Eric Dumazet wrote:
>> On Wed, 2013-08-21 at 17:17 +0200, Johannes Naab wrote:
>>> On 08/20/2013 05:11 PM, Ferry Huberts wrote:
>>>> From: Ferry Huberts <ferry.huberts@pelagic.nl>
>>>>
>>>> Not doing this (current behaviour) introduces reordering.
>>>>
>>>> The packet_len_2_sched_time call is the only thing that logically
>>>> depends on q->rate, so move the now/delay adjustment out of the if.
>>>>
>>>> Signed-off-by: Ferry Huberts <ferry.huberts@pelagic.nl>
>>>> ---
>>>
>>> Hi,
>>>
>>> The documentation for netem does explicitly mention the reordering with
>>> jitter, and gives instructions on how to avoid it. (I have not tested if
>>> it works as intended).
>>
>>
>> Yes.
>>
>> The user specifically adds a random delay of 0 to 510 ms to packets,
>> and expect netem to not reorder packets sent every 100ms.
>>
>> They see netem as a single medium between two endpoints with a guarantee
>> of no reordering, and cumulative delays.
> 
> Well no. We expected no reordering because reordering is not enabled.
> 
> The documentation is very confusing if you compare it to the source
> code, and even incorrect.
> 
> What the code does is (when reordering is disabled):
> - reorders if the rate is NOT set
> - does NOT reorder if the rate is set
> That is quite different, the documentation doesn't even mention the rate
> nor the reordering setting in this context.
> 
> I'm confused on how to proceed now, so CC-ing Hagen Paul Pfeifer
> 
> I'll also discuss this with Teco, who asked me to write up a patch.
> 

I discussed this issue with Teco and we decided to drop thes patches.

We still feel that the behaviour is unexpected and that (at least) the
documentation should be updated to reflect the actual behaviour.

We're going with the fifo approach for now.

So thanks for the feedback and discussions.
And apologies for any disturbances ;-)


Ferry
