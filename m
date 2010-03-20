From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: Reduce timer events for
 addrconf_verify().
Date: Sat, 20 Mar 2010 16:12:51 -0700 (PDT)
Message-ID: <20100320.161251.191388036.davem@davemloft.net>
References: <201003190635.o2J6Z17W016418@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stephen.hemminger@vyatta.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42380
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752515Ab0CTXM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 19:12:29 -0400
In-Reply-To: <201003190635.o2J6Z17W016418@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 18 Mar 2010 18:01:11 +0900

> This patch reduces timer events while keeping accuracy by rounding
> our timer and/or batching several address validations in addrconf_verify().
> 
> addrconf_verify() is called at earliest timeout among interface addresses'
> timeouts, but at maximum ADDR_CHECK_FREQUENCY (120 secs).
> 
> In most cases, all of timeouts of interface addresses are long enough
> (e.g. several hours or days vs 2 minutes), this timer is usually called
> every ADDR_CHECK_FREQUENCY, and it is okay to be lazy.
> (Note this timer could be eliminated if all code paths which modifies
> variables related to timeouts call us manually, but it is another story.)
> 
> However, in other least but important cases, we try keeping accuracy.
> 
> When the real interface address timeout is coming, and the timeout
> is just before the rounded timeout, we accept some error.
> 
> When a timeout has been reached, we also try batching other several
> events in very near future.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
