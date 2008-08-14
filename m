From: Brian Haley <brian.haley@hp.com>
Subject: Re: [Devel] [PATCH 1/2] netns: fix NULL-dereference in dev_net()
Date: Thu, 14 Aug 2008 16:01:34 -0400
Message-ID: <48A48F1E.8050103@hp.com>
References: <48A4871D.1030708@hp.com> <20080814195537.GA8214@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	containers <containers@lists.osdl.org>, netdev@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:10674 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752654AbYHNUBi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Aug 2008 16:01:38 -0400
In-Reply-To: <20080814195537.GA8214@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> On Thu, Aug 14, 2008 at 03:27:25PM -0400, Brian Haley wrote:
>> Change dev_net() to handle a NULL argument - return &init_net instead.
> 
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -781,10 +781,10 @@ static inline
>>  struct net *dev_net(const struct net_device *dev)
>>  {
>>  #ifdef CONFIG_NET_NS
>> -	return dev->nd_net;
>> -#else
>> -	return &init_net;
>> +	if (dev)
>> +		return dev->nd_net;
>>  #endif
>> +	return &init_net;
>>  }
> 
> This is ugly and wrong.
> 
> The only assymetry between init_net and dynamically created netns is
> that some data structures are created only when init_net is initialized
> like some kmem caches and so on.
> 
> And some sysctls that some people may ban in netns.
> 
> Modulo that, init_net is no different from the rest.

So would you rather have all the callers that aren't net-namespace aware 
pass &init_net?  That seemed like a worse solution to me.

-Brian

