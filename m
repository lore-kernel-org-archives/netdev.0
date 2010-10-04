From: Meelis Roos <mroos@linux.ee>
Subject: Re: [PATCH] tms380tr: fix long delays in initialization
Date: Mon, 4 Oct 2010 11:39:02 +0300 (EEST)
Message-ID: <alpine.SOC.1.00.1010041135060.12325@math.ut.ee>
References: <alpine.SOC.1.00.1010032228450.28867@math.ut.ee> <20101003.200109.226763463.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.it.da.ut.ee ([193.40.5.66]:60790 "EHLO smtp1.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753038Ab0JDIjE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 04:39:04 -0400
In-Reply-To: <20101003.200109.226763463.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > tms380tr driver tries to use udelay (meaning busy loop) for several half 
> > second delays during hardware initialization. Crazy overly long busy 
> > wait delays mean no delay at all so driver initialization fails without 
> > waiting. Fix it by using msleep() for long delays and leave it to 
> > udelay() for short delays.
> > 
> > Signed-off-by: Meelis Roos <mroos@linux.ee>
> 
> You can't use msleep() here because this code can be invoked
> from interrupts and thus cannot sleep.

I checked these two functions that contain long delays that I changed - 
tms380tr_bringup_diags() and tms380tr_init_adapter() - to be called only 
from tms380tr_chipset_init() that is only called from tms380tr_open() so 
no call paths from interrupts AFAICS. Short delyas from interrupt 
context are not changed in any way, they still use udelay().

-- 
Meelis Roos (mroos@linux.ee)
