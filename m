From: Patrick McHardy <kaber@trash.net>
Subject: Re: Not understand some in htb_do_events function
Date: Tue, 15 Jan 2008 16:54:41 +0100
Message-ID: <478CD741.7040004@trash.net>
References: <478C86E6.3050508@bigtelecom.ru> <478C87D9.1010305@trash.net> <478CA02A.1070308@cdi.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Badalian Vyacheslav <slavon@bigtelecom.ru>, netdev@vger.kernel.org
To: Martin Devera <devik@cdi.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43226 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbYAOPyy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 10:54:54 -0500
In-Reply-To: <478CA02A.1070308@cdi.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Martin Devera wrote:
> Patrick McHardy wrote:
>> Badalian Vyacheslav wrote:
>>> Hello all.
>>> I have many messages like "htb: too many events !" in dmesg.
>>>
>>> Try to see code and find that function try do 500 events at call.
>>> Hm... may anyone ask why 500? Why its not dynamic value based on 
>>> performance of PC?
>>
>>
>> Thats a good question, I wonder why it is limited at all.
>> Martin, any hints?
>>
> Hi, I recently replied someone to the same question:
> 
>  > it is possible when during one jiffie (1 or 10ms) more than 500 classes
>  > changed its state. It is meant to protect your system from livelock.
>  > The constant should be set to something like
>  > bogomips/bogocomplexity_of_state_change but it was not done.
> 
> the solution I have in my mind is to change
>    if (net_ratelimit())
>                  printk(KERN_WARNING "htb: too many events !\n");
>          return HZ/10;
>  to
>    return 1;
> 
> to drain extra events asap. It the time of writing I was not able to
> come with better solution and there were more bugs related to this
> part of code than now.

So this was meant to protect against endless loops?

> We want way to smooth big burst of events over more dequeue invocations
> in order to not slow dequeue too much. Constant 500 is max. allowed
> "slowdown" of dequeue.
> Any bright idea how to do it more elegant, Patrick ?


Unfortunately not, but I believe simply removing the limit
completely would be better than picking an arbitary value.
