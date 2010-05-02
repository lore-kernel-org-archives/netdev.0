From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Sun, 2 May 2010 10:54:18 -0700
Message-ID: <20100502105418.7abf83a7@infradead.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38756 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758353Ab0EBRwJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 13:52:09 -0400
In-Reply-To: <1272810448.2173.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 02 May 2010 16:27:28 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> C2 latency seems to be 64  (us ?), while C1 seems to be 1

the processor_idle module has a "latency_factor" module parameter.
The default is 2, but sometimes people think 6 is a better value...
.. any chance you can try that value ?

Also, I'm starting to wonder if Andi's patch to use io_schedule() needs
to be replaced with a net_schedule() kind of thing. The cpuidle code
currently has a weight factor for IO (based on measuring/experiments),
and maybe networking really needs another factor... so just having a
parallel concept with a different weight could be the right answer for
that.



> 
> Your CPU supports the following C-states : C1 C2 C3 
> Your BIOS reports the following C-states : C1 C2 
> 
> C3 seems to be disabled in BIOS

btw this C2 == marketing name C3, and C3 == marketing name C6

(too many translations ;-)

we'll fix powertop to report the marketing name soon.


-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org
