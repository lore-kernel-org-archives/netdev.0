From: Karl Hiramoto <karl@hiramoto.org>
Subject: Re: [Linux-ATM-General] [PATCH] atm/br2684: netif_stop_queue() when
 atm device busy and netif_wake_queue() when we can send packets again.
Date: Tue, 15 Sep 2009 16:57:36 +0200
Message-ID: <4AAFAB60.4080302@hiramoto.org>
References: <1251545092-18081-1-git-send-email-karl@hiramoto.org>	<4AA95838.4010007@redfish-solutions.com>	<4AA97004.2010904@hiramoto.org>	<20090911.114848.177667600.davem@davemloft.net> <4AAF9A55.8030207@hiramoto.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caiajhbdcagg.dreamhost.com ([208.97.132.66]:53633 "EHLO
	spunkymail-a11.g.dreamhost.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754538AbZIOO5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 10:57:34 -0400
In-Reply-To: <4AAF9A55.8030207@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Karl Hiramoto wrote:
> David Miller wrote:
>   
>> From: Karl Hiramoto <karl@hiramoto.org>
>> Date: Thu, 10 Sep 2009 23:30:44 +0200
>>
>>   
>>     
>>> I'm not really sure if or how many packets to upper layers buffer.
>>>     
>>>       
>> This is determined by ->tx_queue_len, so whatever value is being
>> set for ATM network devices is what the core will use for backlog
>> limiting while the device's TX queue is stopped.
>>     
> I tried varying tx_queue_len by 10, 100,  and 1000x, but it didn't seem 
> to help much.  Whenever the atm dev called netif_wake_queue() it seems 
> like the driver still starves for packets  and still takes time to get 
> going again.
>
>
> It seem like when the driver calls netif_wake_queue() it's TX hardware 
> queue is nearly full, but it has space to accept new packets.  The TX 
> hardware queue has time to empty, devices starves for packets(goes 
> idle), then finally a packet comes in from the upper networking 
> layers.   I'm not really sure at the moment where the problem lies to my 
> maximum throughput dropping.
>
> I did try changing sk_sndbuf to 256K but that didn't seem to help either.
>
> --
Actually i think i spoke too soon,  tuning TCP parameters, txqueuelen on 
all machines the server, router and client it seems my performance came 
back.

--
Karl

