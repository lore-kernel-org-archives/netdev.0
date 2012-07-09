From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dont use __netdev_alloc_skb for bounce buffer
Date: Sun, 08 Jul 2012 23:52:53 -0700 (PDT)
Message-ID: <20120708.235253.2142432557468408142.davem@davemloft.net>
References: <1341254172.22621.456.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefan.bader@canonical.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752130Ab2GIGwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 02:52:54 -0400
In-Reply-To: <1341254172.22621.456.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Jul 2012 20:36:12 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> commit a1c7fff7e1 (net: netdev_alloc_skb() use build_skb()) broke b44 on
> some 64bit machines.
> 
> It appears b44 and b43 use __netdev_alloc_skb() instead of alloc_skb()
> for their bounce buffers.
> 
> There is no need to add an extra NET_SKB_PAD reservation for bounce
> buffers :
> 
> - In TX path, NET_SKB_PAD is useless
> 
> - In RX path in b44, we force a copy of incoming frames if
>   GFP_DMA allocations were needed.
> 
> Reported-and-bisected-by: Stefan Bader <stefan.bader@canonical.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
