From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 2 May 2010 10:43:04 -0700
Message-ID: <20100502104304.6c6b2764@infradead.org>
References: <20100429182347.GA8512@gargoyle.fritz.box>
	<1272568347.2209.11.camel@edumazet-laptop>
	<20100429214144.GA10663@gargoyle.fritz.box>
	<20100430.163857.180417789.davem@davemloft.net>
	<20100501110000.GB9434@gargoyle.fritz.box>
	<1272783366.2173.13.camel@edumazet-laptop>
	<20100502092020.GA9655@gargoyle.fritz.box>
	<1272797690.2173.26.camel@edumazet-laptop>
	<20100502154649.GA18063@gargoyle.fritz.box>
	<1272818131.2173.127.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:42444 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758076Ab0EBRlL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 13:41:11 -0400
In-Reply-To: <1272818131.2173.127.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 02 May 2010 18:35:31 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote
> 
> 
> You mean we can wakeup a thread with something else than an IPI ?
> 

actually we can.

mwait is not only "go idle", it is "go idle until someone writes to
<THIS> cacheline". where <THIS> is set up with a "monitor" instruction.
We don't need to send an ipi per se.. all we need is to write to the
right cacheline that we're monitoring.


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
