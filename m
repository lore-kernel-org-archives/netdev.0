From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 19:48:03 +0100
Message-ID: <47A217E3.60309@trash.net>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme> <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56306 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759696AbYAaSsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:48:09 -0500
In-Reply-To: <20080131190125.GE4671@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> On Thu, Jan 31, 2008 at 07:21:20PM +0100, Patrick McHardy wrote:
>> Andi Kleen wrote:
>>>> Then change TBF to use skb_gso_segment?  Be careful, the fact that
>>> That doesn't help because it wants to interleave packets
>> >from different streams to get everything fair and smooth. The only 
>>> good way to handle that is to split it up and the simplest way to do 
>>> this is to just tell TCP to not do GSO in the first place.
>>
>> Thats not correct, TBF keeps packets strictly ordered unless
> 
> My point was that without TSO different submitters will interleave
> their streams (because they compete about the qdisc submission) 
> and then you end up with a smooth rate over time for all of them.
> 
> If you submit in large chunks only (as TSO does) it will always 
> be more bursty and that works against the TBF goal.
> 
> For a single submitter you would be correct.


The TBF goal is not really fairness among different flows, but
I agree, avoiding TSO in the first place seems to make more sense.
