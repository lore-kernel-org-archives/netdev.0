From: Julian Anastasov <ja@ssi.bg>
Subject: Re: Stale entries in RT_TABLE_LOCAL
Date: Thu, 10 Mar 2011 02:04:17 +0200 (EET)
Message-ID: <alpine.LFD.2.00.1103100139510.2372@ja.ssi.bg>
References: <201102231243.23579.alexandre.sidorenko@hp.com> <20110309.135308.102544831.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: alexandre.sidorenko@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:38652 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751449Ab1CIX7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Mar 2011 18:59:40 -0500
In-Reply-To: <20110309.135308.102544831.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 	Hello,

On Wed, 9 Mar 2011, David Miller wrote:

> From: Alex Sidorenko <alexandre.sidorenko@hp.com>
> Date: Wed, 23 Feb 2011 12:43:23 -0500
>
>> I am not sure what is the best way to fix this, I can think of several
>> approaches:
>>
>>   (a) change the sources so that it would be impossible to add the same IP
>>       multiple times, even with different masks. I cannot think of any
>>       situation where adding the same IP (but with different mask) to the same
>>       interface could be useful. But maybe I am wrong?
>
> I'm leaning towards this solution if it's viable.  But I'm not so sure that
> nobody uses this feature, maybe Julian knows?
>
> Julian, the issue is that if you add the same IP address multiple times using
> different subnet masks, we allow it.
>
> But removal doesn't work correctly, we clear the IFA list on the device but we
> leave stale entries in the local routing table.
>
> The test case is:
>
> ip addr add 192.168.142.109/23 dev dummy0
> ip addr add 192.168.142.109/22 dev dummy0

 	Here I have just one local route.

> ip addr del 192.168.142.109/22 dev dummy0
> ip addr del 192.168.142.109/23 dev dummy0

 	Hm, my 2.6.34 kernel has no such problem. I have
to do some tests with recent tree tomorrow. But fib_magic uses
NLM_F_CREATE | NLM_F_APPEND but even that can not overcome
the check for equal alias, so I don't think it is possible
two equal FIB aliases to be added. I expect only to see
2 local routes if the IP addresses are added to different
devices. May be for some reason we can not remove the single
local route when last IP is deleted.

 	Alex, what is the kernel version and can you test
it on different kernels? Also, do you really see 2 equal
local routes after the two adds?

Regards

--
Julian Anastasov <ja@ssi.bg>
