From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 2 May 2010 20:50:44 -0700
Message-ID: <20100502205044.450beda2@infradead.org>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	<1272568347.2209.11.camel@edumazet-laptop>
	<20100429214144.GA10663@gargoyle.fritz.box>
	<20100430.163857.180417789.davem@davemloft.net>
	<20100501110000.GB9434@gargoyle.fritz.box>
	<1272783366.2173.13.camel@edumazet-laptop>
	<20100502092020.GA9655@gargoyle.fritz.box>
	<1272797690.2173.26.camel@edumazet-laptop>
	<20100502071324.1a95fdad@infradead.org>
	<1272810448.2173.31.camel@edumazet-laptop>
	<20100502105418.7abf83a7@infradead.org>
	<1272828143.2173.150.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38314 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752912Ab0ECDsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 23:48:47 -0400
In-Reply-To: <1272828143.2173.150.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Also, I'm starting to wonder if Andi's patch to use io_schedule()
> > needs to be replaced with a net_schedule() kind of thing. The
> > cpuidle code currently has a weight factor for IO (based on
> > measuring/experiments), and maybe networking really needs another
> > factor... so just having a parallel concept with a different weight
> > could be the right answer for that.
> > 
> 
> But a task blocked on disk IO is probably blocked for a small amount
> of time, while on network, it can be for a long time. I am not sure
> its the right metric.

it's not so much about the duration, as it is about the performance
sensitivity....

 
> I was expecting something based on recent history.
> Say if we have 20.000 wakeups per second, most likely we should not
> enter C2/C3 states...

we effectively do that. The thing is that C2 is so low cost normally
that it's still worth it even at 20k wakeups...

this is where the bios tells us how "heavy" the states are....
and 64 usec... is just not very much.



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
