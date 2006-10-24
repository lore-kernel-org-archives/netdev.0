From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH REPOST 1/2] NET: Accurate packet scheduling for ATM/ADSL
 (kernel)
Date: Tue, 24 Oct 2006 22:00:27 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0610242135480.22705@ask.diku.dk>
References: <1161041677.6247.1.camel@ras.pc.brisbane.lube>
 <1161090444.5555.13.camel@jzny2>  <45378DE3.8080700@trash.net>
 <1161602527.5502.155.camel@ras.pc.stuart.local>  <453CB801.4010902@trash.net>
 <1161640444.5502.214.camel@ras.pc.stuart.local> <453E3CFC.80007@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Russell Stuart <russell-tcatm@stuart.id.au>, hadi@cyberus.ca,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [130.225.96.91] ([130.225.96.91]:59013 "EHLO mgw1.diku.dk")
	by vger.kernel.org with ESMTP id S1161215AbWJXUAe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 16:00:34 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <453E3CFC.80007@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 24 Oct 2006, Patrick McHardy wrote:

> Russell Stuart wrote:
>> On Mon, 2006-10-23 at 14:39 +0200, Patrick McHardy wrote:
>>
>>> The implementation may be different, but the intention and the
>>> result is the same. I probably would mind less if it wouldn't
>>> affect userspace compatibility, but we need to carry this stuff
>>> for ever even if we add another implementation that covers all
>>> qdiscs.
>>
>>
>> So where is the overlap?  Your patch will make qdiscs
>> that use packet length work with ATM.  Ours makes the
>> rest, ie those that use Alexy's RTAB, work with ATM.
>> They would probably both apply with minimal conflicts.
>> You have previously said you have no intention of
>> changing the current RTAB implantation with your STAB
>> patch.
>
> No, my patch works for qdiscs with and without RTABs, this
> is where they overlap.

Patrick, your patch does not solve the alignment issue of the RTABs.

(The kernel part of) our patch (Me and Russells), simply gives the ability 
to align the RTAB.  We will still need this ability when your STAB patch 
is in place.


<cut>
>
> Sure, I'm just mentioning it. Is seems to be quite deeply codified
> in userspace though.

Yes, the userspace patch is where we do the "ugly" complicated stuff.


<cut>
>>> I'm not sure I understand what you're saying here. The transmission
>>> time gets _smaller_ by transmitting over ATM? Does this have anything
>>> to do with the off-by-one during rate table calculation you or
>>> Jesper noticed?
>>
>>
>> There is nothing I would describe as an "off-by-one
>> error" in the RTAB calculation, so I can't be sure
>> what you are referring to.
>
> Either you or Jesper pointed to this code in iproute:

It was me, Jesper.

>        for (i=0; i<256; i++) {
>                unsigned sz = (i<<cell_log);
> ...
>                rtab[i] = tc_core_usec2tick(1000000*((double)sz/bps));
>
> which tends to underestimate the transmission time by using
> the smallest possible size for each cell.

Correct.
My original patch only corrected this "off-by-one error" (and parsed on an 
overhead argument to the kernel).

Russell, took the step further and made it possible to adjust the 
alignment from userspace.

<cut>


Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
