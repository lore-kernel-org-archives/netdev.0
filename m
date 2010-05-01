From: Martin Josefsson <gandalf@mjufs.se>
Subject: Re: OFT - reserving CPU's for networking
Date: Sat, 1 May 2010 22:31:05 +0200 (CEST)
Message-ID: <Pine.LNX.4.62.1005012222320.24624@wlug.westbo.se>
References: <1272563772.2222.301.camel@edumazet-laptop> <20100429111047.031eeff9@nehalam>
 <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain>
 <20100430.115715.216750975.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: tglx@linutronix.de, shemminger@vyatta.com, eric.dumazet@gmail.com,
	ak@gargoyle.fritz.box, netdev@vger.kernel.org, andi@firstfloor.org,
	peterz@infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host91-201.netintact.se ([194.153.91.201]:49544 "EHLO
	wlug.westbo.se" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753218Ab0EAUzr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 16:55:47 -0400
In-Reply-To: <20100430.115715.216750975.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 30 Apr 2010, David Miller wrote:

> Then we can do cool tricks like having the cpu spin on a mwait() on the
> network device's status descriptor in memory.

Can you have mwait monitor multiple cachelines for stores? If not then it 
might be hard to do that when you have multiple nics and you actually 
need to use the status descriptors, otherwise you could possibly have them 
all written to the same cacheline. 
Or if the nic doesn't support updating a status descriptor in memory.

If you just want to wake up quickly without using interrupts it might be 
possible to abuse MSI to wake up without actually using interrupts, set 
the address to the cacheline that is being monitored.

/Martin
