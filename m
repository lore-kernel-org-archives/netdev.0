From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: use TCP_DEFAULT_INIT_RCVWND in
 tcp_fixup_rcvbuf()
Date: Thu, 20 Oct 2011 15:50:02 -0400 (EDT)
Message-ID: <20111020.155002.555965434596006787.davem@davemloft.net>
References: <1319138186.2854.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35515 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230Ab1JTTuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 15:50:07 -0400
In-Reply-To: <1319138186.2854.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 Oct 2011 21:16:26 +0200

> Since commit 356f039822b (TCP: increase default initial receive
> window.), we allow sender to send 10 (TCP_DEFAULT_INIT_RCVWND) segments.
> 
> Change tcp_fixup_rcvbuf() to reflect this change, even if no real change 
> is expected, since sysctl_tcp_rmem[1] = 87380 and this value
> is bigger than tcp_fixup_rcvbuf() computed rcvmem (~23720)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
 ...
> +	unsigned int mss = min_t(unsigned int, tp->advmss, 1460);

I don't understand where this calculation comes from, and even if it
should be obvious it isn't to me and deserves a mention in the commit
message at a minimum.
