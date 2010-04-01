From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/5] netfilter: xt_TEE: have cloned packet travel through
 Xtables too
Date: Thu, 01 Apr 2010 15:48:12 +0200
Message-ID: <4BB4A41C.7030107@trash.net>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de> <1270031934-15940-6-git-send-email-jengelh@medozas.de> <4BB47768.1050405@trash.net> <alpine.LSU.2.01.1004011258060.17429@obet.zrqbmnf.qr> <4BB47EEA.4020809@trash.net> <alpine.LSU.2.01.1004011511180.1174@obet.zrqbmnf.qr> <4BB49E10.8080608@trash.net> <alpine.LSU.2.01.1004011543260.1174@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52781 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755817Ab0DANsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 09:48:14 -0400
In-Reply-To: <alpine.LSU.2.01.1004011543260.1174@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jan Engelhardt wrote:
> On Thursday 2010-04-01 15:22, Patrick McHardy wrote:
>>>>> Conntrack loops are prevented by using a dummy conntrack, just as 
>>>>> NOTRACK does.
>>>> [...]
>>>>>  - When the cloned packets gets XFRMed or tunneled, its status switches 
>>>>>    from "special" to "plain". Doing policy routing on them does not seem 
>>>>>    so far-fetched.
>>>> My question was about the case without conntrack.
>>> Hm. Do you have any suggestion in countering a case whereby a user
>>> does -I OUTPUT -j TEE without conntrack?
>>>
>>> Perhaps making nesting a feature that requires conntrack, such that the 
>>> non-CT case can't loop?
>> If we drop the reentrancy thing, what should work is to prevent
>> using loopback as output device and using something similar to
>> the recursion counters tunnel devices used to have.
> 
> Nah. I'm going to pick a bit from struct skbuff to indicate the
> packet was teed so as to avoid that loop.

That's a bad idea, we shouldn't be adding new skb members for something
as peripheral as this module.

What's wrong with adding a reentrancy counter?
