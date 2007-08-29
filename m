From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Wed, 29 Aug 2007 10:43:13 +0200
Message-ID: <200708291043.14380.ossthema@de.ibm.com>
References: <200708271147.01890.ossthema@de.ibm.com> <46D51BD7.6040904@de.ibm.com> <46D52B14.8010508@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	shemminger@linux-foundation.org, akepner@sgi.com,
	netdev@vger.kernel.org, raisch@de.ibm.com, themann@de.ibm.com,
	linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	meder@de.ibm.com, tklein@de.ibm.com, stefan.roscher@de.ibm.com
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:26258 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbXH2InR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 04:43:17 -0400
In-Reply-To: <46D52B14.8010508@katalix.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 29 August 2007 10:15, James Chapman wrote:
> Jan-Bernd Themann wrote:
> > What I'm trying to improve with this approach is interrupt
> > mitigation for NICs where the hardware support for interrupt
> > mitigation is limited. I'm not trying to improve this for NICs
> > that work well with the means their HW provides. I'm aware of
> > the fact that this scheme has it's tradeoffs and certainly
> > can not be as good as a HW approach.
> > So I'm grateful for any ideas that do have less tradeoffs and
> > provide a mechanism to reduce interrupts without depending on
> > HW support of the NIC.
> > 
> > In the end I want to reduce the CPU utilization. And one way
> > to do that is LRO which also works only well if there are more
> > then just a very few packets to aggregate. So at least our
> > driver (eHEA) would benefit from a mix of timer based polling
> > and plain NAPI (depending on load situations).
> 
> Wouldn't you achieve the same result by enabling hardware interrupt 
> mitigation in eHEA in combination with NAPI? Presumably a 10G interface 
> has hardware mitigation features?

Quote from above: "What I'm trying to improve with this approach 
is interrupt mitigation for NICs where the hardware support for
interrupt mitigation is limited"

So guess why I'm doing that ;-)

> 
> > If there is no need for a generic mechanism for this kind of
> > network adapters, then we can just leave this to each device
> > driver.
> 
> I've been looking at this from a different angle. My goal is to optimize 
> NAPI packet forwarding rates while minimizing packet latency. Using 
> hardware interrupt mitigation hurts latency so I'm investigating ways to 
> turn it off without risking NAPI poll on/off thrashing at certain packet 
> rates.
> 
> Jan-Bernd, I think I've found a solution to the issue that you 
> highlighted with my scheme yesterday and it doesn't involve generating 
> other interrupts using hrtimers etc. :) Initial results are very 
> encouraging in my setups. Would you be willing to test it with eHEA? I 
> don't have a 10G setup. If results are encouraging, I'll post an RFC to 
> ask for review / feedback from the NAPI experts here. What do you think?
> 

I'm not sure which solution you mean. If you post your RFC, please create
a new thread (other title)

