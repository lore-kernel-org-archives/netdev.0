From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: [PATCH] fix smc911x compilation breakage
Date: Sun, 29 Apr 2007 09:05:12 +0100
Message-ID: <20070429080512.GA855@flint.arm.linux.org.uk>
References: <20070427143552.0000757a.vwool@ru.mvista.com> <4633693B.7070404@pobox.com> <1177783857.1532.4.camel@barja>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, dustin@sensoria.com,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Vitaly Wool <vwool@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([217.147.92.249]:2384 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932771AbXD2IFY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Apr 2007 04:05:24 -0400
Content-Disposition: inline
In-Reply-To: <1177783857.1532.4.camel@barja>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Apr 28, 2007 at 10:10:57PM +0400, Vitaly Wool wrote:
> Hello Jeff,
> 
> > Vitaly Wool wrote:
> > > Index: linux-2.6/drivers/net/smc911x.c
> > > ===================================================================
> > > --- linux-2.6.orig/drivers/net/smc911x.c
> > > +++ linux-2.6/drivers/net/smc911x.c
> > > @@ -75,9 +75,9 @@ static const char version[] =
> > >  #include <linux/netdevice.h>
> > >  #include <linux/etherdevice.h>
> > >  #include <linux/skbuff.h>
> > > +#include <linux/irq.h>
> > >  
> > >  #include <asm/io.h>
> > > -#include <asm/irq.h>
> > >  
> > >  #include "smc911x.h"
> > 
> > This seems to clash with rmk's comment at the top of linux/irq.h?
> 
> In a way, yes, but I just was fixing the compilation problem, and not
> changing the logic in any way. The driver currently calls set_irq_type
> so it has to include linux/irq.h, just as it had to include asm/irq.h
> before.
> 
> I'd guess that set_irq_type better be called by generic code and either
> just make the driver don't even bother or call a callback set by
> platform part. If you're fine with any of these, and think it's better
> than the initial patch, please let me know and I'll proceed with that.

Drivers should really be using IRQF_TRIGGER_* constants, not set_irq_type()
unless they have a very good reason.  I doubt this driver has such a
reason, and it's just coded for an older version of the ARM IRQ API.

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
