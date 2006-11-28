From: David Miller <davem@davemloft.net>
Subject: Re: [patch sungem] improved locking
Date: Tue, 28 Nov 2006 15:43:50 -0800 (PST)
Message-ID: <20061128.154350.02290212.davem@davemloft.net>
References: <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
	<20061128.144911.55733883.davem@davemloft.net>
	<1164754644.5350.110.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.lemoine@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41179
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1757958AbWK1Xnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 18:43:43 -0500
To: benh@kernel.crashing.org
In-Reply-To: <1164754644.5350.110.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 29 Nov 2006 09:57:24 +1100

> 
> > This looks mostly fine.
> > 
> > I was thinking about the lockless stuff, and I wonder if there
> > is a clever way you can get it back down to one PIO on the
> > GREG_STAT register.
> > 
> > I think you'd need to have the ->poll() clear gp->status, then
> > do a smp_wb(), right before it re-enables interrupts.
> > 
> > Then in the interrupt handler, you need to find a way to safely
> > OR-in any unset bits in gp->status in a race-free manner.
> 
> Having it atomic might work at a slightly smaller cost than a lock,
> though atomics don't have strong ordering requirements so you'd still
> have to be a bit careful.

At least in theory the atomic + any necessary memory barriers
would be cheaper than the extra PIO read we need otherwise.
