From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: use a per task frag allocator
Date: Mon, 24 Sep 2012 16:39:46 -0400 (EDT)
Message-ID: <20120924.163946.1641999339438679497.davem@davemloft.net>
References: <CAGK4HS98RG78Auvaai3Ny6zz5c_hccO-ShD3GuT=moRRm4+RUA@mail.gmail.com>
	<1348261871.2669.962.camel@edumazet-glaptop>
	<1348477482.26828.235.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: subramanian.vijay@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, alexander.h.duyck@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54277 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932230Ab2IXUjt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 16:39:49 -0400
In-Reply-To: <1348477482.26828.235.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 24 Sep 2012 11:04:42 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> We currently use a per socket order-0 page cache for tcp_sendmsg()
> operations.
> 
> This page is used to build fragments for skbs.
> 
> Its done to increase probability of coalescing small write() into
> single segments in skbs still in write queue (not yet sent)
> 
> But it wastes a lot of memory for applications handling many mostly
> idle sockets, since each socket holds one page in sk->sk_sndmsg_page
> 
> Its also quite inefficient to build TSO 64KB packets, because we need
> about 16 pages per skb on arches where PAGE_SIZE = 4096, so we hit
> page allocator more than wanted.
> 
> This patch adds a per task frag allocator and uses bigger pages,
> if available. An automatic fallback is done in case of memory pressure.
> 
> (up to 32768 bytes per frag, thats order-3 pages on x86)
> 
> This increases TCP stream performance by 20% on loopback device,
> but also benefits on other network devices, since 8x less frags are
> mapped on transmit and unmapped on tx completion. Alexander Duyck
> mentioned a probable performance win on systems with IOMMU enabled.
> 
> Its possible some SG enabled hardware cant cope with bigger fragments,
> but their ndo_start_xmit() should already handle this, splitting a
> fragment in sub fragments, since some arches have PAGE_SIZE=65536
> 
> Successfully tested on various ethernet devices.
> (ixgbe, igb, bnx2x, tg3, mellanox mlx4)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I'm going to apply this, nice work Eric.

I'll also take care of the trailing whitespace pointed out by others.

Thanks again.
