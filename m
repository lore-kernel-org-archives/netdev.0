From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 19:11:07 +0100
Message-ID: <47A20F3B.1060109@trash.net>
References: <20080131124632.GA25299@basil.nowhere.org>	<20080131092327.75b9c369@extreme>	<20080131183322.GA4671@one.firstfloor.org>	<47A20CDC.5090104@trash.net>	<20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55444 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752974AbYAaSLL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 13:11:11 -0500
In-Reply-To: <20080131100846.00934e25@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Thu, 31 Jan 2008 19:37:35 +0100
> Andi Kleen <andi@firstfloor.org> wrote:
> 
>> On Thu, Jan 31, 2008 at 07:01:00PM +0100, Patrick McHardy wrote:
>>> Andi Kleen wrote:
>>>>> Fix the broken qdisc instead.
>>>> What do you mean? I don't think the qdiscs are broken.
>>>> I cannot think of any way how e.g. TBF can do anything useful
>>>> with large TSO packets.
>>>
>>> Someone posted a patch some time ago to calculate the amount
>>> of tokens needed in max_size portions and use that, but IMO
>>> people should just configure TBF with the proper MTU for TSO.
>> TBF with 64k atomic units will always be chunky and uneven. I don't
>> think that's a useful goal. 
>>
>> -Andi
> 
> Then change TBF to use skb_gso_segment?  Be careful, the fact that
> one skb ends up queueing multiple skb's would cause issues to parent
> qdisc (ie work generating qdisc).


How about keeping the TSO-capable flag on qdiscs, propagating
the non-capability up the tree and perform segmentation before
queueing to the root?
