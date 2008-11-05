From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH] ipv6: fix run pending DAD when interface becomes ready
Date: Wed, 05 Nov 2008 11:28:44 +0100
Message-ID: <4911755C.4030504@bull.net>
References: <20081104135549.981972492@nptl.frec.bull.fr>	<20081104135551.916564770@nptl.frec.bull.fr>	<20081104.145122.25920326.davem@davemloft.net> <20081105.014446.140069453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:51682 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754592AbYKEK24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 05:28:56 -0500
In-Reply-To: <20081105.014446.140069453.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 04 Nov 2008 14:51:22 -0800 (PST)
> 
>> From: Benjamin Thery <benjamin.thery@bull.net>
>> Date: Tue, 04 Nov 2008 14:55:50 +0100
>>
>>> I think there's a bug in net/ipv6/addrconf.c, addrconf_notify():
>>> addrconf_dad_run() is not always run when the interface is flagged IF_READY.
>>> Currently it is only run when receiving NETDEV_CHANGE event. Looks like
>>> some (virtual) devices doesn't send this event when becoming up.
>>>
>>> For both NETDEV_UP and NETDEV_CHANGE events, when the interface becomes
>>> ready, run_pending should be set to 1. Patch below.
>>>
>>> 'run_pending = 1' could be moved below the if/else block but it makes 
>>> the code less readable.

>> I wonder if we should instead make the virtual devices emit
>> the missing event?

I don't know. We'll have to identify all the devices that (mis)behave
like this.
Are all the devices supposed to emit both NETDEV_UP and NETDEV_CHANGE
when ifconfig/ip commands set the devices up?


But as you state below, it also looked more logical to me to run 
addrconf_dad_run() on every events that causes the interface to become
ready.

Benjamin

> 
> In any event, for the time being, I'm going to apply
> Benjamin's patch to fix this problem.
> 
> It makes the function in question logically consistent
> in that now everything that can cause IF_READY to become
> set will also cause run_pending work to run.

This is how

> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
