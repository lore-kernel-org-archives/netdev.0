From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 22:55:06 +0100
Message-ID: <4761AA3A.1000605@gmail.com>
References: <20071213134953.GA3806@ff.dom.local>	<20071213.055013.83963139.davem@davemloft.net>	<4761930C.3030504@gmail.com> <20071213.123727.224454625.davem@davemloft.net> <476198F9.4020004@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, auke-jan.h.kok@intel.com,
	gallatin@myri.com, joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	jesse.brandeburg@intel.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:11579 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762852AbXLMVwA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 16:52:00 -0500
Received: by nf-out-0910.google.com with SMTP id g13so690575nfb.21
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 13:51:58 -0800 (PST)
In-Reply-To: <476198F9.4020004@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote, On 12/13/2007 09:41 PM:

> David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Thu, 13 Dec 2007 21:16:12 +0100
>>
>>   
>>> I see in a nearby thread you would prefer to save some work to drivers
>>> (like this netif_running() check), but I think this all is at the cost
>>> of flexibility, and there will probably appear new problems, when a
>>> driver simply can't wait till the next poll (which btw. looks strange
>>> with all these hotplugging, usb and powersaving).
>>>     
>> As someone who has actually had to edit the NAPI support of _EVERY_
>> single driver in the tree I can tell you that code duplication and
>> subtle semantic differences are a huge issue.
>>
>> And when you talk about driver flexibility, it's wise to mention that
>> this comes at the expense of flexibility in the core implmentation.
>> For example, if we export the list handling widget into the ->poll()
>> routines, god help the person who wants to change how the poll list is
>> managed in net_rx_action() :-/
>>
>> So we don't want to export datastructure details like that to the
>> driver.
   

(I hope you both don't mind I save some 'paper' and do this
2 in 1...)

So, you've seen a few drivers, know this much better than me, and
maybe even thought why they all so unnecessarily different... Of
course, if you think that despite those differences they all can
work with simpler napi api then OK (until they don't have to do
any cheating, like with this 'work' here).

> Also, most of the drivers should/could be doing the same thing. It is 
> seems that
> driver writers just want to get "creative" and do things differently. 
> The code is
> cleaner, safer, and less buggy if every device uses the interface in the 
> same way.
> 
> When I did the initial pass on this, I didn't see a single variation on 
> NAPI usage
> that was better than the simple "get N packets and return" variation.  
> But Dave
> did way more detailed grunt work on this.

It seems there are some differences in thinking what is simple/complex.
I think drivers' developers are used to controlling their devices, so
they know better when to turn on/off interrupts. So, maybe similar model
could be appropriate here. Sometimes doing more looks simpler than doing
less and remembering how and when the rest will be done (like
this netif_running() test). But I hope I'm wrong here, and this will
work after all!

Cheers,
Jarek P.
