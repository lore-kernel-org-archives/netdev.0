From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] netdev sysfs failure handling
Date: Tue, 9 May 2006 14:40:49 -0700
Message-ID: <20060509144049.0924d41c@localhost.localdomain>
References: <20060421134205.2786a0ee@localhost.localdomain>
	<20060506.180622.117885702.davem@davemloft.net>
	<20060509120107.0a999f38@localhost.localdomain>
	<20060509.140501.18000999.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:45960 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751165AbWEIVkx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 May 2006 17:40:53 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060509.140501.18000999.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 09 May 2006 14:05:01 -0700 (PDT)
"David S. Miller" <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Tue, 9 May 2006 12:01:07 -0700
> 
> > Something like this would handle errors better, but introduce possible
> > problems for drivers that call register_netdevice with irq's disabled.
> > There was some comment about racing with linkwatch, but don't see how
> > that could happen during creation.  
> > 
> > For 2.6.18?
> 
> I've been thinking about this a bit more.
> 
> How can anyone be using this with IRQ's disabled if we have
> an ASSERT_RTNL() there?

Agreed, especially since rtnl is now a real mutex.  The case, that
I was worried about:
	rtnl_lock()
	spin_lock_irq(&mylock);
	x = register_netdevice();
...

Doesn't show up in any current code, even for the pseudo devices
and funny virtualized interfaces.
