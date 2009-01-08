From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: dev->get_stats(dev) in COMPAT_NET_DEV_OPS case
Date: Thu, 08 Jan 2009 15:02:28 +0100
Message-ID: <49660774.6060603@hartkopp.net>
References: <4965FBA5.2010605@hartkopp.net> <1231421397.3408.5.camel@hashbaz.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.160]:19504 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751586AbZAHOC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 09:02:29 -0500
In-Reply-To: <1231421397.3408.5.camel@hashbaz.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> On Thu, 2009-01-08 at 14:12 +0100, Oliver Hartkopp wrote:
>   
>> Hello Stephen,
>>
>> in commit eeda3fd64f75bcbfaa70ce946513abaf3f23b8e0 ("netdev: introduce dev_get_stats()")
>> you remove the setting of dev->get_stats :
>>
>> @@ -4370,7  +4384,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
>>  
>>         netdev_init_queues(dev);
>>  
>> -       dev->get_stats = internal_stats;
>>         netpoll_netdev_init(dev);
>>         setup(dev);
>>         strcpy(dev->name, name);
>>
>> I really appreciate your introduction of COMPAT_NET_DEV_OPS but when i 
>> try to compile and run a non-converted driver, i get a NULL pointer 
>> dereference. I tracked it down to be the call of dev->get_stats(dev).
>>
>> Did you miss something or is this behaviour intended?
>>     
>
> You should be calling dev_get_stats() now.
>
>   

I noticed that myself and besides a warning (about the const / non-const 
definition) i got it working again.
But the question remains, if it still makes sense to provide 
dev->get_stats() (referencing to dev_get_stats()) in the 
COMPAT_NET_DEV_OPS case, as i would surely not be the only one tapping 
into this problem ...

Regards,
Oliver

