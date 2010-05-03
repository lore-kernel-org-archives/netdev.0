From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
	input_pkt_queue
Date: Mon, 3 May 2010 17:52:04 +0200
Message-ID: <20100503155204.GA6200@gargoyle.fritz.box>
References: <1272797690.2173.26.camel@edumazet-laptop> <20100502071324.1a95fdad@infradead.org> <1272810448.2173.31.camel@edumazet-laptop> <20100502105418.7abf83a7@infradead.org> <1272828143.2173.150.camel@edumazet-laptop> <20100502205044.450beda2@infradead.org> <1272863834.2173.173.camel@edumazet-laptop> <20100503032227.268613ac@infradead.org> <20100503103426.GA25809@one.firstfloor.org> <20100503070925.572bbee6@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:43164 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075Ab0ECPtd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 11:49:33 -0400
Content-Disposition: inline
In-Reply-To: <20100503070925.572bbee6@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> so the hard problem is that on going idle, the local timers need to be
> funneled to the external HPET. Afaik right now we use one channel of
> the hpet, with the result that we have one global lock for this.
> 
> HPETs have more than one channel (2 or 3 historically, newer chipsets
> iirc have a few more), so in principle we can split this lock at least
> a little bit... if we can get to one hpet channel per level 3 cache
> domain we'd already make huge progress in terms of cost of the
> contention....

I suggested the same thing a few emails up @) (great minds think 
alike etc.etc. @) . 

I'm not sure how difficult it would be to implement though.

Potential issues:

Some user applications use the hpet channels directly through
the character device interface so there would be a potential
compatibility issue (but maybe that should be just moved
to be emulated with a hrtimer ?)

And if multiple broadcast controllers are elected this might
make it harder to become idle.

-Andi
