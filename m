From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/1] ip_tunnel: Create percpu gro_cell
Date: Sun, 18 Jan 2015 01:57:22 -0500 (EST)
Message-ID: <20150118.015722.951803764873668933.davem@davemloft.net>
References: <1421431860-1960597-1-git-send-email-kafai@fb.com>
	<1421431860-1960597-2-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbbARG5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 01:57:24 -0500
In-Reply-To: <1421431860-1960597-2-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 16 Jan 2015 10:11:00 -0800

> In the ipip tunnel, the skb->queue_mapping is lost in ipip_rcv().
> All skb will be queued to the same cell->napi_skbs.  The
> gro_cell_poll is pinned to one core under load.  In production traffic,
> we also see severe rx_dropped in the tunl iface and it is probably due to
> this limit: skb_queue_len(&cell->napi_skbs) > netdev_max_backlog.
> 
> This patch is trying to alloc_percpu(struct gro_cell) and schedule
> gro_cell_poll to process the skb in the same core.
> 
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied, thanks.
