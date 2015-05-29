From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v2] ipv6: Fix protocol resubmission
Date: Fri, 29 May 2015 14:48:27 -0700
Message-ID: <CALx6S34mG6HTtJ5sofLKayMgtJ9EhwCnk9RFX-He8sVBpO9ovg@mail.gmail.com>
References: <1432929886-14259-1-git-send-email-johunt@akamai.com>
	<5568CBCC.1080503@cogentembedded.com>
	<5568DD83.8020600@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:38118 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757036AbbE2Vs2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 17:48:28 -0400
Received: by igbjd9 with SMTP id jd9so24694864igb.1
        for <netdev@vger.kernel.org>; Fri, 29 May 2015 14:48:27 -0700 (PDT)
In-Reply-To: <5568DD83.8020600@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Josh,

Why did you need to move the resubmit label?


On Fri, May 29, 2015 at 2:43 PM, Josh Hunt <johunt@akamai.com> wrote:
> On 05/29/2015 03:27 PM, Sergei Shtylyov wrote:
>>
>> Hello.
>>
>> On 05/29/2015 11:04 PM, Josh Hunt wrote:
>>
>>> I came across this problem while trying to use UDP encapsulation with
>>> IPv6. The
>>> change below fixes that, but it was not immediately apparent if there
>>> are any
>>> other protocols relying on this broken behavior. FWIW the behavior
>>> below now
>>> matches IPv4.
>>
>>
>>> Josh
>>
>>
>>     Need "Signed-off-by:" line insted of this.
>>
>>> v2: Actually sets nexthdr so we can use it ;)
>>
>>
>>     Normally goes after ---, not before.
>>
>>> ---
>>
>>
>>> UDP encapsulation is broken on IPv6 because it expects when it returns
>>> a negative
>>> value that the packet will be resubmitted to the stack with the
>>> handler corresponding
>>> to the return value. The check currently looks for return values > 0
>>> and then resubmits.
>>
>>
>>> This patch fixes that check and also moves the resubmit label to take
>>> advantage of
>>> the return code identifying the next protocol we want to process.
>>
>>
>>> Signed-off-by: Josh Hunt <johunt@akamai.com>
>>> ---
>>>   net/ipv6/ip6_input.c |    7 ++++---
>>>   1 file changed, 4 insertions(+), 3 deletions(-)
>>
>>
>>> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
>>> index f2e464e..e16c289 100644
>>> --- a/net/ipv6/ip6_input.c
>>> +++ b/net/ipv6/ip6_input.c
>>
>> [...]
>>>
>>> @@ -246,9 +246,10 @@ resubmit:
>>>               goto discard;
>>>
>>>           ret = ipprot->handler(skb);
>>> -        if (ret > 0)
>>> +        if (ret < 0) {
>>> +            nexthdr = -ret;
>>>               goto resubmit;
>>> -        else if (ret == 0)
>>> +        } else if (ret == 0)
>>>               IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INDELIVERS);
>>
>>
>>     The CodingStyle dictates that all branches must have {} if at least
>> one has them.
>
>
> Thanks Sergei, I appreciate the review. I will make these changes in a v3
> after I get feedback this is the correct fix for the problem.
>
> Josh
