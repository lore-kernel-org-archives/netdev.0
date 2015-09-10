From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next] Revert "net/ipv6: add sysctl option
 accept_ra_min_hop_limit"
Date: Thu, 10 Sep 2015 14:52:45 +0900
Message-ID: <55F11AAD.3030209@miraclelinux.com>
References: <20150902094301.GA6434@via.ecp.fr>
 <20150902.161110.223512323094619164.davem@davemloft.net>
 <20150909101054.GA6753@bistromath.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	hideaki.yoshifuji@miraclelinux.com,
	Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	liuhangbin@gmail.com
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33418 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbbIJFwt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2015 01:52:49 -0400
Received: by pacex6 with SMTP id ex6so32868231pac.0
        for <netdev@vger.kernel.org>; Wed, 09 Sep 2015 22:52:48 -0700 (PDT)
In-Reply-To: <20150909101054.GA6753@bistromath.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sabrina Dubroca wrote:
> 2015-09-02, 16:11:10 -0700, David Miller wrote:
>> From: Sabrina Dubroca <sd@queasysnail.net>
>> Date: Wed, 2 Sep 2015 11:43:01 +0200
>>
>>> This reverts commit 8013d1d7eafb0589ca766db6b74026f76b7f5cb4.
>>>
>>> There are several issues with this patch.
>>> It completely cancels the security changes introduced by 6fd99094de2b
>>> ("ipv6: Don't reduce hop limit for an interface").
>>> The current default value (min hop limit = 1) can result in the same
>>> denial of service that 6fd99094de2b prevents, but it is hard to define
>>> a correct and sane default value.
>>> More generally, it is yet another IPv6 sysctl, and we already have too
>>> many.
>>>
>>> This was introduced to satisfy a TAHI test case which, in my opinion, is
>>> too strict, turning the RFC's "SHOULD" into a "MUST":
>>>
>>>     If the received Cur Hop Limit value is non-zero, the host
>>>     SHOULD set its CurHopLimit variable to the received value.
>>>
>>> The behavior of this sysctl is wrong in multiple ways.  Some are
>>> fixable, but let's not rush this commit into mainline, and revert this
>>> while we still can, then we can come up with a better solution.
>>>
>>> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
>>
>> I don't agree with this revert.
>>
>> If you look at the original commit, the quoted RFC recommends adding
>> a configurable method to protect against this.
>>
>> And that's exactly what the commit you are trying to revert is doing.
>>
>> The only thing I would entertain is potentially an adjustment of the
>> default, working in concert with the TAHI folks to make sure their
>> tests still pass with any new default.
> 
> Would you agree with a default of 64, as Florian suggested?

1 was chosen to restore our behavior before introduction of current
hoplimit check.  I am not in favor of changing that value.

Plus, 64 is too restrictive and 32 would be enough for global
internet, IMHO.

> 
> 
> Can we still modify the behavior of this sysctl? It's already been in
> Linus's tree for a while, but if we can, I would rather restrict the
> values we let the user write to accept_ra_min_hop_limit, as anything
> outside [0..255] does not really make sense.

[1..256], maybe, but it is not harmful to set outside the range.
0 is always ignored. If it is set to 256 or more, the option is
completely ignored.

> 
> Allowing an RA to update the hop limit if
> 
>    current hop limit < RA.hop_limit < accept_ra_min_hop_limit
> 
> might also be desirable, but I'm not so sure about this case.
> 
> 

It might be... byt I don't think it is a good idea since it becomes
more complex.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
