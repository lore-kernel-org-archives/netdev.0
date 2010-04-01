From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 5/5] netfilter: xt_TEE: have cloned packet travel through
 Xtables too
Date: Thu, 1 Apr 2010 15:15:38 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1004011511180.1174@obet.zrqbmnf.qr>
References: <1270031934-15940-1-git-send-email-jengelh@medozas.de> <1270031934-15940-6-git-send-email-jengelh@medozas.de> <4BB47768.1050405@trash.net> <alpine.LSU.2.01.1004011258060.17429@obet.zrqbmnf.qr> <4BB47EEA.4020809@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4BB47EEA.4020809@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 2010-04-01 13:09, Patrick McHardy wrote:

>> Conntrack loops are prevented by using a dummy conntrack, just as 
>> NOTRACK does.
>[...]
>>  - When the cloned packets gets XFRMed or tunneled, its status switches 
>>    from "special" to "plain". Doing policy routing on them does not seem 
>>    so far-fetched.
>
>My question was about the case without conntrack.

Hm. Do you have any suggestion in countering a case whereby a user
does -I OUTPUT -j TEE without conntrack?

Perhaps making nesting a feature that requires conntrack, such that the 
non-CT case can't loop?

>> I can think of a handful of applications:
>>  - CLASSIFY
>
>Good point, you should probably reset a couple of skb members
>after the skb_copy().

I take it you mean

 nf_reset(skb)
 skb->mark = 0;
 skb_init_secmark(nskb);

Or should we be using skb_alloc and copying the data portion over, like 
ipt_REJECT does since v2.6.24-2931-g9ba99b0?

