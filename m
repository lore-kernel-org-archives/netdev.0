From: Patrick McHardy <kaber@trash.net>
Subject: Re: [IPV4 3/5] fib_trie: dump doesnt use RCU
Date: Thu, 24 Jan 2008 07:47:39 +0100
Message-ID: <4798348B.4080300@trash.net>
References: <20080123224858.918669715@linux-foundation.org>	<20080123.205007.16809712.davem@davemloft.net>	<47983304.3030309@trash.net> <20080123.224337.80401207.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33656 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbYAXGry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 01:47:54 -0500
In-Reply-To: <20080123.224337.80401207.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Thu, 24 Jan 2008 07:41:08 +0100
>
>   
>> David Miller wrote:
>>     
>>> and nothing in that code path retakes the RTNL semaphore.
>>>       
>> Actually we're always holding the rtnl during dumps, nlk->cb_mutex points
>> to rtnl_mutex in case of rtnetlink. It used to be held only during the first
>> ->dump invocation and not on continuations, but I changed this a few 
>> versions ago.
>>     
>
> My bad.  Thanks for the correction Patrick.
>
> But continuations can occur on subsequent recvmsg() calls,
> does it return to userspace with the mutex held?  If so
> I'm pretty sure that's not allowed.
>   

No, the mutex is dropped between different ->dump invocations.

