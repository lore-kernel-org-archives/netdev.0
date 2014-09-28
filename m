From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: change tcp_skb_pcount() location
Date: Sun, 28 Sep 2014 16:37:07 -0400 (EDT)
Message-ID: <20140928.163707.607592212098788571.davem@davemloft.net>
References: <1411557082.15395.24.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com, ycheng@google.com,
	willemb@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbaI1UhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Sep 2014 16:37:09 -0400
In-Reply-To: <1411557082.15395.24.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 24 Sep 2014 04:11:22 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Our goal is to access no more than one cache line access per skb in
> a write or receive queue when doing the various walks.
> 
> After recent TCP_SKB_CB() reorganizations, it is almost done.
> 
> Last part is tcp_skb_pcount() which currently uses
> skb_shinfo(skb)->gso_segs, which is a terrible choice, because it needs
> 3 cache lines in current kernel (skb->head, skb->end, and
> shinfo->gso_segs are all in 3 different cache lines, far from skb->cb)
> 
> This very simple patch reuses space currently taken by tcp_tw_isn
> only in input path, as tcp_skb_pcount is only needed for skb stored in
> write queue.
> 
> This considerably speeds up tcp_ack(), granted we avoid shinfo->tx_flags
> to get SKBTX_ACK_TSTAMP, which seems possible.
> 
> This also speeds up all sack processing in general.
> 
> This speeds up tcp_sendmsg() because it no longer has to access/dirty
> shinfo.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
> Note : This patch applies cleanly after "tcp: better TCP_SKB_CB layout"
> patch serie.

Also applied, thanks Eric.
