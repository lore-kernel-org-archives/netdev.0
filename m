From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2]: [NET_SCHED]: Making rate table lookups more	flexible.
Date: Tue, 04 Sep 2007 18:25:29 +0200
Message-ID: <46DD86F9.8000902@trash.net>
References: <1188562978.18622.13.camel@localhost.localdomain>	 <46D91082.7050609@trash.net>	 <Pine.LNX.4.61.0709012338320.29796@ask.diku.dk>	 <46DACA48.2060602@trash.net>	 <Pine.LNX.4.61.0709022006380.20071@ask.diku.dk>	 <46DB2846.2030400@trash.net> <1188829151.16405.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45185 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753023AbXIDQ0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 12:26:23 -0400
In-Reply-To: <1188829151.16405.10.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Dangaard Brouer wrote:
> On Sun, 2007-09-02 at 23:16 +0200, Patrick McHardy wrote:
> 
>>Jesper Dangaard Brouer wrote:
>>
>>>On Sun, 2 Sep 2007, Patrick McHardy wrote:
>>>
>>>Lets focus on the general case, where the functionality actually is 
>>>needed right away.
>>>
>>>In the general case:
>>>
>>>- The rate table needs to be aligned (cell_align=-1).
>>>  (currently, we miscalculates up to 7 bytes on every lookup)
>>
>>We will always do that, thats a consequence of storing the
>>transmission times for multiples of 8b.
> 
> 
> The issue is that we use the lower boundary for calculating the transmit
> cost. Thus, a 15 bytes packet only have a transmit cost of 8 bytes.


I believe this is something that should be fixed anyway,
its better to overestimate than underestimate to stay
in control of the queue. We could additionally make the
rate tables more finegrained (optionally).

>>>- The existing tc overhead calc can be made more accurate.
>>>  (by adding overhead before doing the lookup, instead of the
>>>   current solution where the rate table is modified with its
>>>   limited resolution)
>>
>>Please demonstrate this with patches (one for the overhead
>>calculation, one for the cell_align thing), then we can
>>continue this discussion.
> 
> 
> I have attached a patch for the overhead calculation.


Thanks, I probably won't get to looking into this until
after the netfilter workshop next week.


