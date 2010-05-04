From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Mon, 3 May 2010 18:10:03 -0700
Message-ID: <20100503181003.3764e625@infradead.org>
References: <1272783366.2173.13.camel@edumazet-laptop>
	<20100502092020.GA9655@gargoyle.fritz.box>
	<1272797690.2173.26.camel@edumazet-laptop>
	<20100502071324.1a95fdad@infradead.org>
	<1272810448.2173.31.camel@edumazet-laptop>
	<20100502105418.7abf83a7@infradead.org>
	<1272828143.2173.150.camel@edumazet-laptop>
	<20100502205044.450beda2@infradead.org>
	<1272863834.2173.173.camel@edumazet-laptop>
	<20100503032227.268613ac@infradead.org>
	<20100503103426.GA25809@one.firstfloor.org>
	<20100503070925.572bbee6@infradead.org>
	<4BDEE173.4070800@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49583 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753401Ab0EDBIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 21:08:00 -0400
In-Reply-To: <4BDEE173.4070800@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 03 May 2010 10:45:07 -0400
Brian Bloniarz <bmb@athenacr

> > so the hard problem is that on going idle, the local timers need to
> > be funneled to the external HPET. Afaik right now we use one
> > channel of the hpet, with the result that we have one global lock
> > for this.
> 
> Does the HPET only need to be programmed when going idle?

correct; when going idle the per logical CPU timer value needs
to be put in the global HPET (assuming 1 channel is in use).
This "global" is where the lock comes in.

> That could mean that this isn't a big performance issue.
> cares if you spin for a while when you're about to sleep for
> at least 60usec?

depends on how long the sleep is ;-)


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
