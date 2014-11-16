From: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
Subject: Re: [PATCH] net/at91_ether: fix loading when macb is compiled as a
 module
Date: Sun, 16 Nov 2014 21:32:38 +0100
Message-ID: <20141116203238.GL4656@sisyphus.hd.free.fr>
References: <1416161106-27498-1-git-send-email-gilles.chanteperdrix@xenomai.org>
 <20141116.135302.1339801219762777528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nicolas.ferre@atmel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-51317.dedibox.fr ([62.210.215.82]:38287 "EHLO
	sd-51317.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722AbaKPUcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2014 15:32:45 -0500
Content-Disposition: inline
In-Reply-To: <20141116.135302.1339801219762777528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 16, 2014 at 01:53:02PM -0500, David Miller wrote:
> From: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
> Date: Sun, 16 Nov 2014 19:05:06 +0100
> 
> > The at91_ether driver depends on symbols defined in the macb driver.
> > 
> > Currently, when compiling both at91_ether and macb as module, starting
> > the at91_ether module fails, because the macb module can not be loaded
> > with a macb interface.
> > 
> > Avoid this issue by getting the macb module initialization routine to
> > always return 0, even when no macb device is detected.
> > 
> > Signed-off-by: Gilles Chanteperdrix <gilles.chanteperdrix@xenomai.org>
> 
> This is not acceptable, sorry.
> 
> This means the module stays in memory even if nobody has a real use
> for it.
> 
> You'll need to find another solution, and I'll say in passing that this
> was very poorly designed and that's why the problem exists.
> 

Ok, I see multiple possible other fixes:
- inline the shared functions in the macb.h driver or move them to a
library, this effectively means duplication, but who is going to
enable both drivers anyway?
- when both drivers are compiled as module, make one module
containing both drivers say at91+macb.ko
- modify the code I posted so that it only keeps the macb driver
loaded without macb device if IS_ENABLED(CONFIG_ARM_AT91_ETHER)
and probably many others I do not see.

I just do not know which one you would find acceptable.

Regards.

-- 
					    Gilles.
