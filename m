From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix hostap registration order
Date: Thu, 09 Dec 2010 19:53:15 -0800 (PST)
Message-ID: <20101209.195315.193716225.davem@davemloft.net>
References: <alpine.SOC.1.00.1012100020110.26229@math.ut.ee>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, j@w1.fi, linux-wireless@vger.kernel.org
To: mroos@linux.ee
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52666
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753877Ab0LJDwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 22:52:47 -0500
In-Reply-To: <alpine.SOC.1.00.1012100020110.26229@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Meelis Roos <mroos@linux.ee>
Date: Fri, 10 Dec 2010 01:19:23 +0200 (EET)

> In 2.6.37-rc4, hostap_pci init gives a WARNING with backtrace telling 
> that netif_stop_queue is called before register_netdev. Fix it by moving 
> this call after register_netdev. Removes the warning and seems to work, 
> but why is the call to netif_stop_queue needed at all after 
> register_netdev?
> 
> Signed-off-by: Meelis Roos <mroos@linux.ee>

It should simply not touch the queue state at all at this point.

Your change would add a race.  At the moment the device is registered
it can be brought up, and then your code will eroneously modify
the queue state.
