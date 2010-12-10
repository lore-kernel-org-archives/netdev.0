From: Meelis Roos <mroos@linux.ee>
Subject: Re: [PATCH] fix hostap registration order
Date: Fri, 10 Dec 2010 09:19:51 +0200 (EET)
Message-ID: <alpine.SOC.1.00.1012100918300.15996@math.ut.ee>
References: <alpine.SOC.1.00.1012100020110.26229@math.ut.ee> <20101209.195315.193716225.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: j@w1.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:43705 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751325Ab0LJHTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 02:19:53 -0500
In-Reply-To: <20101209.195315.193716225.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > In 2.6.37-rc4, hostap_pci init gives a WARNING with backtrace telling 
> > that netif_stop_queue is called before register_netdev. Fix it by moving 
> > this call after register_netdev. Removes the warning and seems to work, 
> > but why is the call to netif_stop_queue needed at all after 
> > register_netdev?
> 
> It should simply not touch the queue state at all at this point.
> 
> Your change would add a race.  At the moment the device is registered
> it can be brought up, and then your code will eroneously modify
> the queue state.

OK, I can make a simpler patch for that but I would like to understand 
the original reasons for having netif_stop_queue there. Just a relict or 
still somehow important?

Jouni?

-- 
Meelis Roos (mroos@linux.ee)
