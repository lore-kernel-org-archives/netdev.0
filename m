From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [patch sungem] improved locking
Date: Wed, 29 Nov 2006 09:57:24 +1100
Message-ID: <1164754644.5350.110.camel@localhost.localdomain>
References: <5cac192f0611132328i52d6d615g28d8c493dc028621@mail.gmail.com>
	 <20061113.234456.78492515.davem@davemloft.net>
	 <5cac192f0611141354l3a4aa130ve741c9d6a7a49d0a@mail.gmail.com>
	 <20061128.144911.55733883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eric.lemoine@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:207 "EHLO gate.crashing.org")
	by vger.kernel.org with ESMTP id S1755510AbWK1W5e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Nov 2006 17:57:34 -0500
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061128.144911.55733883.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> This looks mostly fine.
> 
> I was thinking about the lockless stuff, and I wonder if there
> is a clever way you can get it back down to one PIO on the
> GREG_STAT register.
> 
> I think you'd need to have the ->poll() clear gp->status, then
> do a smp_wb(), right before it re-enables interrupts.
> 
> Then in the interrupt handler, you need to find a way to safely
> OR-in any unset bits in gp->status in a race-free manner.

Having it atomic might work at a slightly smaller cost than a lock,
though atomics don't have strong ordering requirements so you'd still
have to be a bit careful.

Ben.


