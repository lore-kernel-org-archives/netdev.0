From: David Miller <davem@davemloft.net>
Subject: Re: OFT - reserving CPU's for networking
Date: Fri, 30 Apr 2010 11:57:15 -0700 (PDT)
Message-ID: <20100430.115715.216750975.davem@davemloft.net>
References: <1272563772.2222.301.camel@edumazet-laptop>
	<20100429111047.031eeff9@nehalam>
	<alpine.LFD.2.00.1004292055471.2951@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, eric.dumazet@gmail.com,
	ak@gargoyle.fritz.box, netdev@vger.kernel.org, andi@firstfloor.org,
	peterz@infradead.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44264
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933780Ab0D3S5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 14:57:10 -0400
In-Reply-To: <alpine.LFD.2.00.1004292055471.2951@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Gleixner <tglx@linutronix.de>
Date: Thu, 29 Apr 2010 21:19:36 +0200 (CEST)

> Aside of that I seriously doubt that you can do networking w/o time
> and timers.

You're right that we need timestamps and the like.

But only if we actually process the packets on these restricted cpus :-)

If we use RPS and farm out all packets to other cpus, ie. just doing
the driver work and the remote cpu dispatch on these "offline" cpus,
it is doable.

Then we can do cool tricks like having the cpu spin on a mwait() on the
network device's status descriptor in memory.

In any event I agree with you, it's a cool idea at best, and likely
not really practical.
