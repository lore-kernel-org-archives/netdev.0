From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] netfilter: xt_TEE: have cloned packet travel through
 Xtables too
Date: Thu, 01 Apr 2010 16:03:02 +0200
Message-ID: <4BB4A796.8010708@trash.net>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de> <1270031934-15940-6-git-send-email-jengelh@medozas.de> <4BB47768.1050405@trash.net> <alpine.LSU.2.01.1004011258060.17429@obet.zrqbmnf.qr> <4BB47EEA.4020809@trash.net> <alpine.LSU.2.01.1004011511180.1174@obet.zrqbmnf.qr> <4BB49E10.8080608@trash.net> <alpine.LSU.2.01.1004011543260.1174@obet.zrqbmnf.qr> <4BB4A41C.7030107@trash.net> <alpine.LSU.2.01.1004011557270.5368@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1004011557270.5368@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jan Engelhardt wrote:
> On Thursday 2010-04-01 15:48, Patrick McHardy wrote:
>> Jan Engelhardt wrote:
>>> On Thursday 2010-04-01 15:22, Patrick McHardy wrote:
>>>>>>> Conntrack loops are prevented by using a dummy conntrack, just as 
>>>>>>> NOTRACK does.
>>>>>> [...]
>>>>>>>  - When the cloned packets gets XFRMed or tunneled, its status switches 
>>>>>>>    from "special" to "plain". Doing policy routing on them does not seem 
>>>>>>>    so far-fetched.
>>>>>> My question was about the case without conntrack.
>>>>> Hm. Do you have any suggestion in countering a case whereby a user
>>>>> does -I OUTPUT -j TEE without conntrack?
>>>>>
>>>>> Perhaps making nesting a feature that requires conntrack, such that the 
>>>>> non-CT case can't loop?
>>>> If we drop the reentrancy thing, what should work is to prevent
>>>> using loopback as output device and using something similar to
>>>> the recursion counters tunnel devices used to have.
>>> Nah. I'm going to pick a bit from struct skbuff to indicate the
>>> packet was teed so as to avoid that loop.
>> That's a bad idea, we shouldn't be adding new skb members for something
>> as peripheral as this module.
> 
> I would have done this, which does not add a member:
> 
> 	IP6CB(skb)->flags |= IPSKB_CLONED;

This doesn't work, the CB is not preserved across layers
(which f.i. matters if you allow loopback destinations).
Its also not preserved for clones.

>> What's wrong with adding a reentrancy counter?
> 
> Sounds like a plan.


