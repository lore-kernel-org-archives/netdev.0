From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Mon, 3 May 2010 18:11:45 -0700
Message-ID: <20100503181145.4e39c2dd@infradead.org>
References: <1272797690.2173.26.camel@edumazet-laptop>
	<20100502071324.1a95fdad@infradead.org>
	<1272810448.2173.31.camel@edumazet-laptop>
	<20100502105418.7abf83a7@infradead.org>
	<1272828143.2173.150.camel@edumazet-laptop>
	<20100502205044.450beda2@infradead.org>
	<1272863834.2173.173.camel@edumazet-laptop>
	<20100503032227.268613ac@infradead.org>
	<20100503103426.GA25809@one.firstfloor.org>
	<20100503070925.572bbee6@infradead.org>
	<20100503155204.GA6200@gargoyle.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49599 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750719Ab0EDBJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 21:09:36 -0400
In-Reply-To: <20100503155204.GA6200@gargoyle.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 3 May 2010 17:52:04 +0200
Andi Kleen <andi@firstfloor.org> wrote:
> > HPETs have more than one channel (2 or 3 historically, newer
> > chipsets iirc have a few more), so in principle we can split this
> > lock at least a little bit... if we can get to one hpet channel per
> > level 3 cache domain we'd already make huge progress in terms of
> > cost of the contention....
> 
> I suggested the same thing a few emails up @) (great minds think 
> alike etc.etc. @) . 
> 
> I'm not sure how difficult it would be to implement though.

the hardest part will be cases where the SMM code borrows higher HPET
channels or something.. not sure if they do, but.. color me a bit afraid
we'll find cases.


> 
> Potential issues:
> 
> Some user applications use the hpet channels directly through
> the character device interface so there would be a potential
> compatibility issue (but maybe that should be just moved
> to be emulated with a hrtimer ?)

we can and should just emulate this. Same for the rtc device I suspect.

 
> And if multiple broadcast controllers are elected this might
> make it harder to become idle.

not quite, as long as you do a directed broadcast. As long as there's a
predictable mapping for which cores group to which hpet channel.. won't
be that bad since you only need to wake up your own local subset.



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
