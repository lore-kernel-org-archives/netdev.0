From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Tue, 12 Jun 2007 01:01:21 +0200
Message-ID: <466DD441.7020505@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC32902F91748@orsmsx414.amr.corp.intel.com>	 <1181082517.4062.31.camel@localhost>  <4666CEB7.6030804@trash.net>	 <1181168020.4064.46.camel@localhost>  <466D38CF.9060709@trash.net>	 <1181564611.4043.220.camel@localhost>  <466D4284.1030004@trash.net>	 <1181566335.4043.231.camel@localhost>  <466D480F.6090708@trash.net>	 <1181568598.4043.250.camel@localhost>  <466D5623.7060708@trash.net>	 <1181572815.4077.13.camel@localhost>  <466D6105.9050305@trash.net>	 <1181574306.4077.34.camel@localhost>  <466D667B.6050108@trash.net>	 <1181575549.4077.50.camel@localhost>  <466D6DF6.9060300@trash.net> <1181597718.4071.12.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54006 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbXFKXD7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2007 19:03:59 -0400
In-Reply-To: <1181597718.4071.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2007-11-06 at 17:44 +0200, Patrick McHardy wrote:
> 
>>jamal wrote:
> 
> [..]
> 
>>>- let the driver shutdown whenever a ring is full. Remember which ring X
>>>shut it down.
>>>- when you get a tx interupt or prun tx descriptors, if a ring <= X has
>>>transmitted a packet (or threshold of packets), then wake up the driver
>>>(i.e open up). 
>>
>>
>>At this point the qdisc might send new packets. What do you do when a
>>packet for a full ring arrives?
>>
> 
> 
> Hrm... ok, is this a trick question or i am missing the obvious?;->
> What is wrong with what any driver would do today - which is:
> netif_stop and return BUSY; core requeues the packet?


That doesn't fix the problem, high priority queues may be starved
by low priority queues if you do that.

BTW, I missed something you said before:

--quote--
 i am making the case that it does not affect the overall results
as long as you use the same parameterization on qdisc and hardware.
--end quote--

I agree that multiple queue states wouldn't be necessary if they
would be parameterized the same, in that case we wouldn't even
need the qdisc at all (as you're saying). But one of the
parameters is the maximum queue length, and we want to be able
to parameterize the qdisc differently than the hardware here.
Which is the only reason for the possible starvation.
