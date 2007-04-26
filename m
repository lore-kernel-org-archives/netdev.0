From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [PATCH] IPROUTE: Modify tc for new PRIO multiqueue behavior
Date: Thu, 26 Apr 2007 09:50:28 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC32902B97173@orsmsx414.amr.corp.intel.com>
References: <4630D6E9.7090201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hadi@cyberus.ca>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	<netdev@vger.kernel.org>, <jgarzik@pobox.com>,
	"cramerj" <cramerj@intel.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Leech, Christopher" <christopher.leech@intel.com>,
	<davem@davemloft.net>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4288 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754837AbXDZQud convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 12:50:33 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4630D6E9.7090201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Waskiewicz Jr, Peter P wrote:
> >>I wouldn't object to putting this into a completely new scheduler
> >>(sch_multiqueue) though since the scheduling policy might 
> be something 
> >>completely different than strict priority.
> > 
> > 
> > We have plans to write a new qdisc that has no priority 
> given to any 
> > skb's being sent to the driver.
> 
> 
> I'm not sure I understand correctly, "no priority" == single 
> band qdisc?

No.  We'd have a qdisc that has a configurable number of bands, ideally
configured to have a 1-1 mapping with the number of queues on your NIC,
that would round-robin into the device.  Then whatever policy your
device has will be the policy packets are transmitted with.  This could
be a configurable policy in the driver, but at that point, it's
device-specific, and the OS won't care about it, which is good.

> 
> > The reasoning for providing a
> > multiqueue mode for PRIO is it's a well-known qdisc, so the 
> hope was 
> > people could quickly associate with what's going on.  The other 
> > reasoning is we wanted to provide a way to prioritize 
> various network 
> > flows (ala PRIO), and since hardware doesn't currently exist that 
> > provides flow prioritization, we decided to allow it to continue 
> > happening in software.
> 
> 
> Any qdisc serving multiple queues needs some scheduling 
> policy to decide which one to dequeue in case multiple queues 
> are active, so a new qdisc might as well also use strict 
> priority. Two reasons why it might make sense to add a new 
> qdisc are a) the hardware scheduling policy could be 
> something different than prio, like WRR, so a neutral name 
> like sch_multiqueue seems more fitting and b) you don't have 
> to figure out how to pass the new parameter to prio without 
> breaking compatibility.
> 
> >>The wireless multiqueue scheduler is pratically identical 
> to this one, 
> >>modulo the wireless classifier that should be a seperate module 
> >>anyway.
> > 
> > 
> > Yi Zhu from the wireless world has been active with me in this 
> > development effort.  He and I are copresenting a paper at 
> OLS on this 
> > specific topic, so I have been getting a perspective from 
> the wireless 
> > world.
> > 
> > I'd like to know if anyone has looked at the actual kernel patches, 
> > instead of the tiny patch to tc here, since that might answer many 
> > questions or concerns being presented here.  :-)
> 
> 
> I did and I'm fine with the current patches if you get rid of 
> the prio ABI breakage. Using a new scheduler is just a 
> suggestion, but I think it would be cleaner to do so.

Sounds good.  I'll get a fix for PRIO so the multiqueue option isn't
required and allow older versions of TC to work with the new PRIO.  I'm
not dismissing the new scheduler idea either, since it's our intent to
develop one for generic multiqueue, much like you suggested.

Thanks for the feedback.  I'll try to get the ABI fixed up asap.

-PJ Waskiewicz
