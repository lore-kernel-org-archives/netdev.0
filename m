From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] fix smc911x compilation breakage
Date: Sat, 28 Apr 2007 11:33:15 -0400
Message-ID: <4633693B.7070404@pobox.com>
References: <20070427143552.0000757a.vwool@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dustin@sensoria.com, netdev@vger.kernel.org,
	Russell King <rmk+lkml@arm.linux.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>
To: Vitaly Wool <vwool@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52167 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161806AbXD1PdS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 11:33:18 -0400
In-Reply-To: <20070427143552.0000757a.vwool@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Vitaly Wool wrote:
> Hi Jeff,
> 
> currently (with 2.6.21) compilation of smc911x driver fails in the following way:
> 
>   CC      drivers/net/smc911x.o
> /sandbox/vital/opensource/linux-2.6/drivers/net/smc911x.c: In function `smc911x_probe':
> /sandbox/vital/opensource/linux-2.6/drivers/net/smc911x.c:2125: warning: implicit declaration of function `set_irq_type'
> /sandbox/vital/opensource/linux-2.6/drivers/net/smc911x.c:2125: error: `IRQ_TYPE_EDGE_FALLING' undeclared (first use in this function)
> /sandbox/vital/opensource/linux-2.6/drivers/net/smc911x.c:2125: error: (Each undeclared identifier is reported only once
> /sandbox/vital/opensource/linux-2.6/drivers/net/smc911x.c:2125: error: for each function it appears in.)
> make[3]: *** [drivers/net/smc911x.o] Error 1
> make[2]: *** [drivers/net] Error 2
> make[1]: *** [drivers] Error 2
> make: *** [zImage] Error 2
> 
> The patch inlined below fixes the problem.
> 
>  smc911x.c |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
> 
> Signed-off-by: Vitaly Wool <vitalywool@gmail.com>
> 
> Index: linux-2.6/drivers/net/smc911x.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/smc911x.c
> +++ linux-2.6/drivers/net/smc911x.c
> @@ -75,9 +75,9 @@ static const char version[] =
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
>  #include <linux/skbuff.h>
> +#include <linux/irq.h>
>  
>  #include <asm/io.h>
> -#include <asm/irq.h>
>  
>  #include "smc911x.h"

This seems to clash with rmk's comment at the top of linux/irq.h?

	Jeff


