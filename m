From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 2 May 2010 07:13:24 -0700
Message-ID: <20100502071324.1a95fdad@infradead.org>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	<1272568347.2209.11.camel@edumazet-laptop>
	<20100429214144.GA10663@gargoyle.fritz.box>
	<20100430.163857.180417789.davem@davemloft.net>
	<20100501110000.GB9434@gargoyle.fritz.box>
	<1272783366.2173.13.camel@edumazet-laptop>
	<20100502092020.GA9655@gargoyle.fritz.box>
	<1272797690.2173.26.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:45630 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756150Ab0EBOL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 10:11:26 -0400
In-Reply-To: <1272797690.2173.26.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> Cn                Avg residency       P-states (frequencies)
> C0 (cpu running)        (68.9%)         2.93 Ghz    46.5%
> polling           0.0ms ( 0.0%)         2.80 Ghz     5.1%
> C1 mwait          0.0ms ( 0.0%)         2.53 Ghz     3.0%
> C2 mwait          0.0ms (31.1%)         2.13 Ghz     2.8%
>                                         1.60 Ghz    38.2%

I bet your system advertizes C2 with the same latency as C1,
but with lower power... which means Linux will pretty much never
pick C1.... no matter how much you take Andi's patch.

this is a bios thing... and until we put in the patch to override the
bios values (I can dust it off but it might need a bit of tweaking
since it was against .31) Andi's patch alone won't cut it... you also
need a non-lying bios ;)



-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
