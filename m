From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next] Revert "net/ipv6: add sysctl option
 accept_ra_min_hop_limit"
Date: Fri, 11 Sep 2015 12:08:40 +0900
Message-ID: <55F245B8.3060903@miraclelinux.com>
References: <20150902094301.GA6434@via.ecp.fr>
 <20150902.161110.223512323094619164.davem@davemloft.net>
 <20150909101054.GA6753@bistromath.redhat.com>
 <55F11AAD.3030209@miraclelinux.com>
 <20150910094037.GB22575@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	David Miller <davem@davemloft.net>,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	liuhangbin@gmail.com
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:32910 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750860AbbIKDIn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 23:08:43 -0400
Received: by pacex6 with SMTP id ex6so61335547pac.0
        for <netdev@vger.kernel.org>; Thu, 10 Sep 2015 20:08:43 -0700 (PDT)
In-Reply-To: <20150910094037.GB22575@bistromath.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Sabrina Dubroca wrote:
> 2015-09-10, 14:52:45 +0900, YOSHIFUJI Hideaki wrote:
>> Sabrina Dubroca wrote:
>>> 2015-09-02, 16:11:10 -0700, David Miller wrote:
>>>> The only thing I would entertain is potentially an adjustment of the
>>>> default, working in concert with the TAHI folks to make sure their
>>>> tests still pass with any new default.
>>>
>>> Would you agree with a default of 64, as Florian suggested?
>>
>> 1 was chosen to restore our behavior before introduction of current
>> hoplimit check.  I am not in favor of changing that value.
> 
> But our old behavior had a security issue, which is why the >= current
> check was introduced.

We have the knob to "protect" ourselves now but it has drawbacks no to
accept lower values than specified.  We can never have ultimate default
for everybody.  The knob might "mitigate" the issue but once we have
any rouge routers on our L2, we lose anyway.  So, I do want to keep it
as-is not to change our traditional behavior.

> 
> 
>> Plus, 64 is too restrictive and 32 would be enough for global
>> internet, IMHO.
> 
> I guess I could live with that, if 32 is indeed enough for everybody.
> 
> 
>>> Can we still modify the behavior of this sysctl? It's already been in
>>> Linus's tree for a while, but if we can, I would rather restrict the
>>> values we let the user write to accept_ra_min_hop_limit, as anything
>>> outside [0..255] does not really make sense.
>>
>> [1..256], maybe, but it is not harmful to set outside the range.
>> 0 is always ignored. If it is set to 256 or more, the option is
>> completely ignored.
> 
> Not harmful, but maybe slightly misleading, and requires the "< 256"
> check when processing a RA.

The "Cur Hop Limit" field is 8bit long...

> 
> 
>>> Allowing an RA to update the hop limit if
>>>
>>>    current hop limit < RA.hop_limit < accept_ra_min_hop_limit
>>>
>>> might also be desirable, but I'm not so sure about this case.
>>>
>>>
>>
>> It might be... byt I don't think it is a good idea since it becomes
>> more complex.
> 
> A bit more complex, yes.  But I don't think this should hold us back
> if it results in better behavior.
> 
> 
> Thanks,
> 

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
