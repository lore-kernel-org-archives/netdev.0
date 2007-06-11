From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 16:03:15 +0200
Message-ID: <466D5623.7060708@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net> <1181568598.4043.250.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43426 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbXFKOFo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 10:05:44 -0400
In-Reply-To: <1181568598.4043.250.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-11-06 at 15:03 +0200, Patrick McHardy wrote:
> 
>>>Take a step back:
>>>When you put a packet on the DMA ring, are you ever going to take it
>>>away at some point before it goes to the wire? 
>>
>>
>>No, but its nevertheless not on the wire yet and the HW scheduler
>>controls when it will get there. 
>>
>>It might in theory even never get
>>there if higher priority queues are continously active.
> 
> 
> Sure - but what is wrong with that? 


Nothing, this was just to illustrate why I disagree with the assumption
that the packet has hit the wire. On second thought I do agree with your
assumption for the single HW queue case, at the point we hand the packet
to the HW the packet order is determined and is unchangeable. But this
is not the case if the hardware includes its own scheduler. The qdisc
is simply not fully in charge anymore.

> What would be wrong is in the case of contention for a resource like a
> wire between a less important packet and a more important packet, the
> more important packet gets favored.


Read again what I wrote about the n > 2 case. Low priority queues might
starve high priority queues when using a single queue state for a
maximum of the time it takes to service n - 2 queues with max_qlen - 1
packets queued plus the time for a single packet. Thats assuming the
worst case of n - 2 queues with max_qlen - 1 packets and the lowest
priority queue full, so the queue is stopped until we can send at
least one lowest priority packet, which requires to fully service
all higher priority queues previously.

> Nothing like that ever happens in what i described.
> Remember there is no issue if there is no congestion or contention for
> local resources.


Your basic assumption seems to be that the qdisc is still in charge
of when packets get sent. This isn't the case if there is another
scheduler after the qdisc and there is contention in the second
queue.
