From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix syncookie regression
Date: Sun, 11 Mar 2012 15:54:33 -0700 (PDT)
Message-ID: <20120311.155433.1130321864592795162.davem@davemloft.net>
References: <1331401490.2453.28.camel@edumazet-laptop>
	<1331402182.2453.30.camel@edumazet-laptop>
	<1331407221.2453.42.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sim@netnation.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41923 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754166Ab2CKWyg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Mar 2012 18:54:36 -0400
In-Reply-To: <1331407221.2453.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 10 Mar 2012 11:20:21 -0800

> commit ea4fc0d619 (ipv4: Don't use rt->rt_{src,dst} in ip_queue_xmit())
> added a serious regression on synflood handling.
> 
> Simon Kirby discovered a successful connection was delayed by 20 seconds
> before being responsive.
> 
> In my tests, I discovered that xmit frames were lost, and needed ~4
> retransmits and a socket dst rebuild before being really sent.
> 
> In case of syncookie initiated connection, we use a different path to
> initialize the socket dst, and inet->cork.fl.u.ip4 is left cleared.
> 
> As ip_queue_xmit() now depends on inet flow being setup, fix this by
> copying the temp flowi4 we use in cookie_v4_check().
> 
> Reported-by: Simon Kirby <sim@netnation.com>
> Bisected-by: Simon Kirby <sim@netnation.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Tested-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied and queued up for -stable, thanks.
