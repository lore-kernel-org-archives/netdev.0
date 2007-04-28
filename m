From: Vitaly Wool <vwool@ru.mvista.com>
Subject: Re: [PATCH] fix smc911x compilation breakage
Date: Sat, 28 Apr 2007 22:10:57 +0400
Message-ID: <1177783857.1532.4.camel@barja>
References: <20070427143552.0000757a.vwool@ru.mvista.com>
	 <4633693B.7070404@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com, netdev@vger.kernel.org,
	Russell King <rmk+lkml@arm.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:48675 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1163423AbXD1SLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2007 14:11:00 -0400
In-Reply-To: <4633693B.7070404@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Jeff,

> Vitaly Wool wrote:
> > Index: linux-2.6/drivers/net/smc911x.c
> > ===================================================================
> > --- linux-2.6.orig/drivers/net/smc911x.c
> > +++ linux-2.6/drivers/net/smc911x.c
> > @@ -75,9 +75,9 @@ static const char version[] =
> >  #include <linux/netdevice.h>
> >  #include <linux/etherdevice.h>
> >  #include <linux/skbuff.h>
> > +#include <linux/irq.h>
> >  
> >  #include <asm/io.h>
> > -#include <asm/irq.h>
> >  
> >  #include "smc911x.h"
> 
> This seems to clash with rmk's comment at the top of linux/irq.h?

In a way, yes, but I just was fixing the compilation problem, and not
changing the logic in any way. The driver currently calls set_irq_type
so it has to include linux/irq.h, just as it had to include asm/irq.h
before.

I'd guess that set_irq_type better be called by generic code and either
just make the driver don't even bother or call a callback set by
platform part. If you're fine with any of these, and think it's better
than the initial patch, please let me know and I'll proceed with that.

Thanks,
   Vitaly

