From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Mon, 11 Jun 2007 15:03:11 +0200
Message-ID: <466D480F.6090708@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net> <1181566335.4043.231.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42039 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751356AbXFKNFj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 09:05:39 -0400
In-Reply-To: <1181566335.4043.231.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-11-06 at 14:39 +0200, Patrick McHardy wrote:
> 
>>>Sure. Packets stashed on the any DMA ring are considered "gone to the
>>>wire". That is a very valid assumption to make.
>>
>>
>>I disagree, its obviously not true 
> 
> 
> Patrick, you are making too strong a statement.


Well, its not.

> Take a step back:
> When you put a packet on the DMA ring, are you ever going to take it
> away at some point before it goes to the wire? 


No, but its nevertheless not on the wire yet and the HW scheduler
controls when it will get there. It might in theory even never get
there if higher priority queues are continously active.

>>and leads to the behaviour I
>>described. If it were true there would be no reason to use multiple
>>HW TX queues to begin with.
> 
> 
> In the general case, they are totaly useless.
> They are  useful when theres contention/congestion. Even in a shared
> media like wireless. 


The same is true for any work-conserving queue, software or hardware.

> And if there is contention, the qdisc scheduler will do the right thing.


That ignores a few points that were raised in this thread,

- you can treat each HW queue as an indivdual network device
- you can avoid synchronizing on a single queue lock for
  multiple TX queues
- it is desirable to keep all queues full
