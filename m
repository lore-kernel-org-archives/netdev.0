From: David Miller <davem@davemloft.net>
Subject: Re: linux-3.0.x regression with ipv4 routes having mtu
Date: Mon, 19 Dec 2011 16:10:53 -0500 (EST)
Message-ID: <20111219.161053.148816799233666803.davem@davemloft.net>
References: <20111214.125010.82857701285437834.davem@davemloft.net>
	<20111215134957.GI6348@secunet.com>
	<20111216122147.GJ6348@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59010 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752361Ab1LSVLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 16:11:02 -0500
In-Reply-To: <20111216122147.GJ6348@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Fri, 16 Dec 2011 13:21:47 +0100

> Subject: [PATCH] route: Initialize with the fib_metrics in the non default case
> 
> We initialize the routing metrics with the cached values in
> rt_init_metrics(). So if we have the metrics cached on the
> inetpeer, we ignore the user configured fib_metrics. So
> initialize the routing metrics with the fib_metrics if they
> are different from dst_default_metrics.
> 
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

The current behavior is intentional.

Learned metrics should be used on all routes for which a inetpeer
peer exists and the destination matches.

There is no sane way to allow overrides.

I'm pretty sure all of Timo's bugs will be fixed when you add the
generation count for PMTU stuff.
