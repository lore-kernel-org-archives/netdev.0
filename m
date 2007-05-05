From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 10/11][TG3]: Reduce spurious interrupts.
Date: Fri, 04 May 2007 20:42:43 -0400
Message-ID: <463BD303.7000500@garzik.org>
References: <1178326521.4859.26.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:53284 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423710AbXEEAmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:42:46 -0400
In-Reply-To: <1178326521.4859.26.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> [TG3]: Reduce spurious interrupts.
> 
> Spurious interrupts are often encountered especially on systems
> using the 8259 PIC mode.  This is because the I/O write to deassert
> the interrupt is posted and won't get to the chip immediately.  As
> a result, the IRQ may remain asserted after the IRQ handler exits,
> causing spurious interrupts.
> 
> An unconditional read to flush the I/O write to force the IRQ to de-
> assert immediately is not desirable because it impacts performance in
> the fast path.  So we only do this after we have some indications of
> spurious interrupts.
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

hmmmm, this is a bit questionable that it needs to be here.

I think it's just a fact of life that it is important to flush certain 
writes...

I'm not sure a driver needs to be adding code to avoid the obvious 
solution.  It would be annoying if all drivers had code to do this.

	Jeff



