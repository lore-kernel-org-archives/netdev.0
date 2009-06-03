From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH iproute2] Re: HTB accuracy for high speed
Date: Wed, 03 Jun 2009 09:53:11 +0200
Message-ID: <4A262BE7.4090807@trash.net>
References: <20090530200756.GF3166@ami.dom.local> <298f5c050906020312r514c4638sfa2b504f55d71bc1@mail.gmail.com> <298f5c050906020445n3941b4ceic1167a4a028005bf@mail.gmail.com> <20090602123635.GC4239@ff.dom.local> <4A251EEE.4060903@trash.net> <20090602130857.GA7690@ff.dom.local> <4A252714.2020008@trash.net> <20090602213723.GB2850@ami.dom.local> <4A259EB2.5010500@gmail.com> <4A2620FD.8030708@trash.net> <20090603074049.GA5254@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Antonio Almeida <vexwek@gmail.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, davem@davemloft.net, devik@cdi.cz,
	Eric Dumazet <dada1@cosmosbay.com>,
	Vladimir Ivashchenko <hazard@francoudi.com>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:60223 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754562AbZFCHxM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 03:53:12 -0400
In-Reply-To: <20090603074049.GA5254@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Wed, Jun 03, 2009 at 09:06:37AM +0200, Patrick McHardy wrote:
>> Mid-term we really need to move to 64 bit values and ns resolution,
>> otherwise this problem is just going to reappear as soon as someone
>> tries 10gbit. Not sure what the best short term fix is, I feel a bit
>> uneasy about changing the current factors given how close this brings
>> us towards overflowing.
> 
> I completely agree it's on the verge of overflow, and actually would
> overflow for some insanely low (for today's standards) rates. So I
> treat it's as a temporary solution, until people start asking about
> more than 1 or 2Gbit. And of course we will have to move to 64 bit
> anyway. Or we can do it now...

That (now) would certainly be the best solution, but its a non-trivial
task since all the ABIs use 32 bit values.

> Btw., I've some doubts about HFSC; it's really different than others
> wrt. rate tables/time accounting, and these PSCHED_TICKS look only
> like an unnecesary compatibility; it works OK with usecs and doesn't
> need this change now, unless I miss something. So maybe we would
> simply stop using common psched_get_time() for it, and only do a
> conversion for qdisc_watchdog_schedule() etc.?

Yes, it would work perfectly fine with usecs, which is actually (and
unfortunately) the unit it uses in its ABI. But I think its better
to convert the values once during initialization, instead of again
and again when scheduling the watchdog. The necessary changes are
really trivial, all you need to do when changing the scaling factors
is to increase SM_MASK and decrease ISM_MASK accordingly.
