From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: Re: RFC: issues concerning the next NAPI interface
Date: Wed, 29 Aug 2007 09:10:15 +0200
Message-ID: <46D51BD7.6040904@de.ibm.com>
References: <200708271147.01890.ossthema@de.ibm.com> <20070827.133721.59473971.davem@davemloft.net> <200708281319.03903.ossthema@de.ibm.com> <20070828.132152.38706038.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, shemminger@linux-foundation.org,
	akepner@sgi.com, netdev@vger.kernel.org, raisch@de.ibm.com,
	themann@de.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, meder@de.ibm.com, tklein@de.ibm.com,
	stefan.roscher@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:64811 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750727AbXH2HK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 03:10:56 -0400
In-Reply-To: <20070828.132152.38706038.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

David Miller schrieb:
> Interrupt mitigation only works if it helps you avoid interrupts.
> This scheme potentially makes more of them happen.
>
> The hrtimer is just another interrupt, a cpu locally triggered one,
> but it has much of the same costs nonetheless.
>
> So if you set this timer, it triggers, and no packets arrive, you are
> taking more interrupts and doing more work than if you had disabled
> NAPI.
>
> In fact, for certain packet rates, your scheme would result in
> twice as many interrupts than the current scheme
>   
That depends how smart the driver switches between timer
polling and plain NAPI (depending on load situation).
> This is one of several reasons why hardware is the only truly proper
> place for this kind of logic.  Only the hardware can see the packet
> arrive, and do the interrupt deferral without any cpu intervention
> whatsoever.
>   
What I'm trying to improve with this approach is interrupt
mitigation for NICs where the hardware support for interrupt
mitigation is limited. I'm not trying to improve this for NICs
that work well with the means their HW provides. I'm aware of
the fact that this scheme has it's tradeoffs and certainly
can not be as good as a HW approach.
So I'm grateful for any ideas that do have less tradeoffs and
provide a mechanism to reduce interrupts without depending on
HW support of the NIC.

In the end I want to reduce the CPU utilization. And one way
to do that is LRO which also works only well if there are more
then just a very few packets to aggregate. So at least our
driver (eHEA) would benefit from a mix of timer based polling
and plain NAPI (depending on load situations).

If there is no need for a generic mechanism for this kind of
network adapters, then we can just leave this to each device
driver.




