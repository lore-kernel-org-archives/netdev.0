From: Patrick McHardy <kaber@trash.net>
Subject: Re: Multiqueue and virtualization WAS(Re: [PATCH 3/3] NET: [SCHED]
 Qdisc changes and sch_rr added for multiqueue
Date: Fri, 29 Jun 2007 13:59:23 +0200
Message-ID: <4684F41B.9080309@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329031F0648@orsmsx414.amr.corp.intel.com>	 <46840AF5.4020209@trash.net>	 <20070628.212032.108743475.davem@davemloft.net> <1183117415.5156.61.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42979 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760477AbXF2L7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 07:59:33 -0400
In-Reply-To: <1183117415.5156.61.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Thu, 2007-28-06 at 21:20 -0700, David Miller wrote:
> 
>>Each guest gets a unique MAC address.  There is a queue per-port
>>that can fill up.
>>
>>What all the drivers like this do right now is stop the queue if
>>any of the per-port queues fill up, and that's why my sunvnet
>>driver does right now as well.  We can only thus wakeup the
>>queue when all of the ports have some space.
> 
> 
> Is a netdevice really the correct construct for the host side?
> Sounds to me a layer above the netdevice is the way to go. A bridge for
> example or L3 routing or even simple tc classify/redirection etc.
> I havent used what has become openvz these days in many years (or played
> with Erics approach), but if i recall correctly - it used to have a
> single netdevice per guest on the host. Thats close to what a basic
> qemu/UML has today. In such a case it is something above netdevices
> which does the guest selection.


I'm guessing that that wouldn't allow to do unicast filtering for
the guests on the real device without hacking the bridge code for
this special case. The difference to a real bridge is that the
all addresses are completely known in advance, so it doesn't need
promiscous mode for learning.
