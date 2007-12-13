From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC] net: napi fix
Date: Thu, 13 Dec 2007 12:41:29 -0800
Message-ID: <476198F9.4020004@linux-foundation.org>
References: <20071213134953.GA3806@ff.dom.local>	<20071213.055013.83963139.davem@davemloft.net>	<4761930C.3030504@gmail.com> <20071213.123727.224454625.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, auke-jan.h.kok@intel.com, gallatin@myri.com,
	joonwpark81@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	jesse.brandeburg@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44491 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757399AbXLMUr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 15:47:28 -0500
In-Reply-To: <20071213.123727.224454625.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Thu, 13 Dec 2007 21:16:12 +0100
>
>   
>> I see in a nearby thread you would prefer to save some work to drivers
>> (like this netif_running() check), but I think this all is at the cost
>> of flexibility, and there will probably appear new problems, when a
>> driver simply can't wait till the next poll (which btw. looks strange
>> with all these hotplugging, usb and powersaving).
>>     
>
> As someone who has actually had to edit the NAPI support of _EVERY_
> single driver in the tree I can tell you that code duplication and
> subtle semantic differences are a huge issue.
>
> And when you talk about driver flexibility, it's wise to mention that
> this comes at the expense of flexibility in the core implmentation.
> For example, if we export the list handling widget into the ->poll()
> routines, god help the person who wants to change how the poll list is
> managed in net_rx_action() :-/
>
> So we don't want to export datastructure details like that to the
> driver.
>   
Also, most of the drivers should/could be doing the same thing. It is 
seems that
driver writers just want to get "creative" and do things differently. 
The code is
cleaner, safer, and less buggy if every device uses the interface in the 
same way.

When I did the initial pass on this, I didn't see a single variation on 
NAPI usage
that was better than the simple "get N packets and return" variation.  
But Dave
did way more detailed grunt work on this.
