From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: [Linux-ATM-General] [PATCH] atm/br2684: netif_stop_queue() when
 atm device busy and netif_wake_queue() when we can send packets again.
Date: Wed, 16 Sep 2009 11:04:49 -0700
Message-ID: <4AB128C1.6010303@redfish-solutions.com>
References: <1251545092-18081-1-git-send-email-karl@hiramoto.org>	<4AA95838.4010007@redfish-solutions.com>	<4AA97004.2010904@hiramoto.org>	<20090911.114848.177667600.davem@davemloft.net>	<4AAF9A55.8030207@hiramoto.org> <4AAFAB60.4080302@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-atm-general@lists.sourceforge.net
To: Karl Hiramoto <karl@hiramoto.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:43309 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753929AbZIPSFV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 14:05:21 -0400
In-Reply-To: <4AAFAB60.4080302@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2009 07:57 AM, Karl Hiramoto wrote:
> Karl Hiramoto wrote:
>   
>> David Miller wrote:
>>   
>>     
>>> From: Karl Hiramoto <karl@hiramoto.org>
>>> Date: Thu, 10 Sep 2009 23:30:44 +0200
>>>
>>>   
>>>     
>>>       
>>>> I'm not really sure if or how many packets to upper layers buffer.
>>>>     
>>>>       
>>>>         
>>> This is determined by ->tx_queue_len, so whatever value is being
>>> set for ATM network devices is what the core will use for backlog
>>> limiting while the device's TX queue is stopped.
>>>     
>>>       
>> I tried varying tx_queue_len by 10, 100,  and 1000x, but it didn't seem 
>> to help much.  Whenever the atm dev called netif_wake_queue() it seems 
>> like the driver still starves for packets  and still takes time to get 
>> going again.
>>
>>
>> It seem like when the driver calls netif_wake_queue() it's TX hardware 
>> queue is nearly full, but it has space to accept new packets.  The TX 
>> hardware queue has time to empty, devices starves for packets(goes 
>> idle), then finally a packet comes in from the upper networking 
>> layers.   I'm not really sure at the moment where the problem lies to my 
>> maximum throughput dropping.
>>
>> I did try changing sk_sndbuf to 256K but that didn't seem to help either.
>>
>> --
>>     
> Actually i think i spoke too soon,  tuning TCP parameters, txqueuelen on 
> all machines the server, router and client it seems my performance came 
> back.
>
> --
> Karl
>   

So what size are you currently using?

Out-of-the-box build, 2.6.27.29 seems to set it to 1000.

-Philip

