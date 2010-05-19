From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: dev_get_valid_name buggy with hash collision
Date: Wed, 19 May 2010 21:39:56 +0200
Message-ID: <4BF43E8C.3000708@free.fr>
References: <4BF26926.4070507@free.fr> <201005181529.37420.opurdila@ixiacom.com> <4BF2AA68.5090008@free.fr> <201005192005.49459.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:51344 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605Ab0ESTj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 15:39:59 -0400
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate5.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o4JJdwca016818
	for <netdev@vger.kernel.org>; Wed, 19 May 2010 19:39:58 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4JJdwtE1118442
	for <netdev@vger.kernel.org>; Wed, 19 May 2010 20:39:58 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4JJdw0X010529
	for <netdev@vger.kernel.org>; Wed, 19 May 2010 20:39:58 +0100
In-Reply-To: <201005192005.49459.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2010 07:05 PM, Octavian Purdila wrote:
> On Tuesday 18 May 2010 17:55:36 you wrote:
>
>    
>>>>          if (!dev_valid_name(name))
>>>>                  return -EINVAL;
>>>>
>>>>          if (fmt&&   strchr(name, '%'))
>>>> -               return __dev_alloc_name(net, name, buf);
>>>> +               return dev_alloc_name(dev, name);
>>>>          else if (__dev_get_by_name(net, name))
>>>>                  return -EEXIST;
>>>> -       else if (buf != name)
>>>> -               strlcpy(buf, name, IFNAMSIZ);
>>>> +       else if (strncmp(dev->name, name, IFNAMSIZ))
>>>> +                strlcpy(dev->name, name, IFNAMSIZ);
>>>>          
>>> Why do the strncmp, can't we preserve the (buf != name) condition
>>>        
>> The 'buf' parameter is no longer passed to the function. We have the
>> 'dev'  and the 'newname' parameters.
>> The pointer test was just to check 'dev_get_valid_name' was called from
>> the 'register_netdevice' function context with 'dev_get_valid_name(net,
>> dev->name, dev->name, 0)'. Comparing the strings is valid in this case.
>>
>> Otherwise dev_get_valid_name is called from:
>>
>>    *  "dev_change_net_namespace" with "dev%d" or "ifname" specified
>> within the netlink message. Both are different pointers, the first will
>> fall in the "if (fmt&&  strchr(name, '%'))".
>>
>>    * "dev_change_name", where the pointers are different and the strings
>> are different.
>>
>>      
> True, but we why not use "if (dev->name !=name)" instead of strncmp? It should
> yield the same results and it is lighter then full strncmp.
>    

Yes, I agree. In the context of the different callers, that's correct.
Will resend it with the pointer comparison.

Thanks
   -- Daniel
