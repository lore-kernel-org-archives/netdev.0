From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] net/dst: dst_dev_event() called after other notifiers
Date: Tue, 09 Nov 2010 12:11:21 -0800
Message-ID: <4CD9AAE9.2050209@candelatech.com>
References: <4CD893C6.2030803@candelatech.com>	<1289331475.2774.41.camel@edumazet-laptop> <20101109.114853.193732360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:49191 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385Ab0KIULY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Nov 2010 15:11:24 -0500
In-Reply-To: <20101109.114853.193732360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2010 11:48 AM, David Miller wrote:
> From: Eric Dumazet<eric.dumazet@gmail.com>
> Date: Tue, 09 Nov 2010 20:37:55 +0100
>
>> [PATCH] net/dst: dst_dev_event() called after other notifiers
>
> Nice, applied.
>
> However, I had to apply this by hand:
>
>>   static struct notifier_block dst_dev_notifier = {
>>   	.notifier_call  = dst_dev_event,
>> +	.priority = -10, /* must be called after other network notifiers */
>>   };
>
> The character after ".notifier_call" in my tree is a TAB character but
> in your patch it is a sequence of spaces.  This isn't looking like the
> usual email corruption, because the leading TAB characters on these
> lines are properly there.
>
> Please figure out why this happened so that it doesn't repeat in
> future patches :-)

I manually applied this as well and can confirm that interface deletion
with a global IPv6 address on it is now comparable to any other device
delete (about 30ms).

Tested-by:  Ben Greear <greearb@candelatech.com>

I'd love to test patches that made all interface deletes faster,
btw :)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

