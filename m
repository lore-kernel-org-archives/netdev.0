From: Andi Kleen <andi@firstfloor.org>
Subject: Re: OFT - reserving CPU's for networking
Date: Fri, 30 Apr 2010 23:01:31 +0200
Message-ID: <20100430210131.GA2833@gargoyle.fritz.box>
References: <1272563772.2222.301.camel@edumazet-laptop> <20100429111047.031eeff9@nehalam> <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain> <20100430.115715.216750975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tglx@linutronix.de, shemminger@vyatta.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:57231 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752161Ab0D3U7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 16:59:00 -0400
Content-Disposition: inline
In-Reply-To: <20100430.115715.216750975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Then we can do cool tricks like having the cpu spin on a mwait() on the
> network device's status descriptor in memory.

When you specify a deep C state in that mwait then it will also have the long 
wakeup latency in the idle case.  When you don't then you just killed higher
Turbo mode on that socket and give away a lot of performance on the other
cores.

So you have to solve the idle state governour issue anyways, and then
you likely don't need it anymore.

Besides it seems to me that dispatching is something the NIC should
just do directly. "RPS only CPU" would be essentially just an 
interrupt mitigation/flow redirection scheme that a lot of NICs
do anyways.

> In any event I agree with you, it's a cool idea at best, and likely
> not really practical.

s/cool//

-Andi
