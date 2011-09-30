From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH next 2/7] 8139cp : removal of headers.
Date: Fri, 30 Sep 2011 18:26:49 +0200
Message-ID: <20110930162649.GA32195@electric-eye.fr.zoreil.com>
References: <20110930103604.GA26727@electric-eye.fr.zoreil.com> <20110930103719.GC26727@electric-eye.fr.zoreil.com> <1317391428.4068.36.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49014 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757400Ab1I3Q21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 12:28:27 -0400
Content-Disposition: inline
In-Reply-To: <1317391428.4068.36.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> :
[...]
> > diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> > index c77d5af..60c8de5 100644
> > --- a/drivers/net/ethernet/realtek/8139cp.c
> > +++ b/drivers/net/ethernet/realtek/8139cp.c
> > @@ -55,8 +55,6 @@
> >  
> >  #include <linux/module.h>
> >  #include <linux/moduleparam.h>
> > -#include <linux/kernel.h>
> 
> Needed for container_of.
> 
> > -#include <linux/compiler.h>
> 
> Needed for __packed.  But it's probably safe to assume that
> <linux/kernel.h> will include it.

<linux/module.h> would include it too.

Being modular opens the doors for a lot of features. :o|

[...]
> > @@ -65,7 +63,6 @@
> >  #include <linux/dma-mapping.h>
> >  #include <linux/delay.h>
> >  #include <linux/ethtool.h>
> > -#include <linux/gfp.h>
> 
> Needed for GFP_KERNEL.

I would have assumed that <linux/dma-mapping.h> provides it as it
publicizes gfp_t dependant data.


I am sceptical about the value in including so much headers for
rather common things at the network device driver level. After all
the code is supposed to be cross-platform, modular or monolithic
built.

I can understand that even a single class of devices requires some
variation but including kernel.h, init.h, module.h and moduleparam.h
all around in drivers/net seems a bit silly. Same thing for including
both netdevice.h and etherdevice.h.

It's probably not worth the hassle. I'll drop it.

-- 
Ueimor
