From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH 10/11][TG3]: Reduce spurious interrupts.
Date: Fri, 04 May 2007 18:45:58 -0700
Message-ID: <1178329558.4859.38.camel@dell>
References: <1178326521.4859.26.camel@dell>
 <463BD303.7000500@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	"netdev" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2328 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031014AbXEEA6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:58:43 -0400
In-Reply-To: <463BD303.7000500@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-05-04 at 20:42 -0400, Jeff Garzik wrote:
> Michael Chan wrote:
> > [TG3]: Reduce spurious interrupts.
> > 
> > Spurious interrupts are often encountered especially on systems
> > using the 8259 PIC mode.  This is because the I/O write to deassert
> > the interrupt is posted and won't get to the chip immediately.  As
> > a result, the IRQ may remain asserted after the IRQ handler exits,
> > causing spurious interrupts.
> > 
> > An unconditional read to flush the I/O write to force the IRQ to de-
> > assert immediately is not desirable because it impacts performance in
> > the fast path.  So we only do this after we have some indications of
> > spurious interrupts.
> > 
> > Signed-off-by: Michael Chan <mchan@broadcom.com>
> 
> hmmmm, this is a bit questionable that it needs to be here.
> 
> I think it's just a fact of life that it is important to flush certain 
> writes...
> 
> I'm not sure a driver needs to be adding code to avoid the obvious 
> solution.  It would be annoying if all drivers had code to do this.

We had a discussion about 2 years ago and David decided to remove the
I/O read to improve performance.  Since then a small number of users
have been complaining about spurious interrupts.  We can add back the
unconditional read or do this detection thing which I agree is somewhat
annoying.  David, what do you think?

