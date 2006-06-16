From: Grant Grundler <grundler@parisc-linux.org>
Subject: Re: PATCHv3 2.6.17-rc5 tulip free_irq() called too late
Date: Fri, 16 Jun 2006 10:06:23 -0600
Message-ID: <20060616160623.GF7868@colo.lackof.org>
References: <20060614044412.GA30552@colo.lackof.org> <44902554.7010703@pobox.com> <20060614181419.GA10365@colo.lackof.org> <20060614204720.GA17887@electric-eye.fr.zoreil.com> <20060614223021.GB13212@colo.lackof.org> <20060615203017.GA6724@electric-eye.fr.zoreil.com> <20060616054711.GA28524@colo.lackof.org> <44925EA8.5070906@pobox.com> <20060616152400.GA7868@colo.lackof.org> <4492CE98.50900@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Valerie Henson <val_henson@linux.intel.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:29908 "EHLO colo.lackof.org")
	by vger.kernel.org with ESMTP id S1751410AbWFPQG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2006 12:06:26 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4492CE98.50900@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[ Jeff, apologies. I hit "reply" instead of "group reply" on previous email.
  I've added everyone back on the cc list.]

On Fri, Jun 16, 2006 at 11:30:32AM -0400, Jeff Garzik wrote:
...
> >Are you saying this sequence won't mask interrupts on tulip?
> >
> >        /* Disable interrupts by clearing the interrupt mask. */
> >        iowrite32 (0x00000000, ioaddr + CSR7);
> >        ioread32 (ioaddr + CSR7);       /* flush posted write */
> 
> It does not stop the generation of interrupt events.

This use of "interrupt events" is misleading.
The CPU does not sees these "interrupt events" once we mask interrupts.

> The DMA engine is still running, packets are still being received.
> The above code sequence does not change that.

I agree. And I'm asking why does anyone care?
We clean that up after IRQs are stopped from being delivered to the CPU.

...
> >Secondly, since you have ignored the two previous times I've asked,
> >I'll presume you agree that if firmware leaves it in this state
> >(pending, masked interrupts), that the driver has to (and does)
> >handle it.
> 
> There is no firmware involved here, at any level, after boot.

I agree.  What about at boot time?

> The needed task in the driver has been the same since this thread 
> started:  (1) stop generating new work [stop DMA engine], and (2) 
> quiesce the hardware.  And it must happen in that order.

No it doesn't. I've proven it works in the order I've proposed
on pretty damn anal HW.

> Setting the interrupt mask register to zero doesn't stop new work from 
> appearing.

I agree. It stops the "screaming interrupt" problem. The fact that we
are in "close" or "down" routine means the user already decided
they don't care if new packets do or do not arrive.

Unless you can point to a real user who is affected by
my proposed patch, I ask again patch v3 be accepted.

thanks,
grant
