From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 8/9] vxge: Acquire correct lock based on
 interrupt context.
Date: Mon, 05 Oct 2009 21:18:52 -0700 (PDT)
Message-ID: <20091005.211852.12665189.davem@davemloft.net>
References: <Pine.GSO.4.10.10910050757300.9377-100000@guinness>
	<20091005.053759.74765905.davem@davemloft.net>
	<78C9135A3D2ECE4B8162EBDCE82CAD7705C16322@nekter>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sreenivasa.Honnur@neterion.com, netdev@vger.kernel.org
To: Ramkrishna.Vepa@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49992
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750805AbZJFETI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2009 00:19:08 -0400
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD7705C16322@nekter>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Date: Mon, 5 Oct 2009 22:36:22 -0400

>> > - Added macros that check if the thread is in interrupt context or
> not
>> to
>> >   acquire or release locks
>> >
>> > Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
>> 
>> There is nothing at all wrong with using irqsave/irqrestore spin lock
>> calls when you're already in an interrupt.
>> 
>> I don't see any reason for this change.
> [Ram] Right, but why have the additional step of saving and restoring
> the flags while in the interrupt context?

Do you know that in the interrupt handler, cpu interrupts are
actually enabled?

And the cost is (relatively speaking) next to nothing.  You're
in the process of taking cache misses and toucing PIO registers
(on the order of thousands of cycles).

Not doing a IRQ save/restore is going to save you a hand full
of cycles.

The new branch mispredict you might get there is probably more
expensive or of equal expense to the IRQ save/restore itself.

This change makes really no sense, NO OTHER DRIVER does crap
like this.  Because there is no reason to.
