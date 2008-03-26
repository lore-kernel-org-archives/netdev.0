From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Improvev netconsole support for RTL8139 NIC driver
Date: Tue, 25 Mar 2008 23:14:03 -0400
Message-ID: <47E9BF7B.3030003@pobox.com>
References: <47E9B115.9060109@windriver.com>	<47E9B39C.5010502@pobox.com> <20080325.194221.16658596.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yang.shi@windriver.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59820 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751281AbYCZDOH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Mar 2008 23:14:07 -0400
In-Reply-To: <20080325.194221.16658596.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Jeff Garzik <jgarzik@pobox.com>
> Date: Tue, 25 Mar 2008 22:23:24 -0400
> 
>> This is bogus -- you should never need to slow down the hot path in such 
>> a way.
> 
> Slow down in what way?  Even on x86 saving the flags is just
> about as expensive as a plain sti/cli.

Replacing spin_lock() [current 8139too.c] with spin_lock_irqsave() 
results in a larger interrupt handler... more CPU instructions for the 
same result.


> I would in fact prefer to see drivers unconditionally use
> spin_lock_irqsave() et al. in the interrupt handler, for
> consistency.

The entire spin_lock() apparatus in the interrupt handler disappears 
nicely on uniprocessor machines.

Plus, you are not competing with any other interrupts other than your 
own, which is the only major class of problems where spin_lock_irqsave() 
in interrupt handler is really needed (PS/2 kbd + mouse is an example).

Or more simply, it's not needed, so nothing is gained by doing 
additional work in the hot path for the sake of consistency.

	Jeff


