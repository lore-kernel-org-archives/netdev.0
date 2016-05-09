From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH V1 0/3] net: enable use of kmem_cache_alloc_bulk in
 network stack
Date: Mon, 09 May 2016 15:44:24 +0200
Message-ID: <20160509134352.3573.37044.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, gerlitz.or@gmail.com, eugenia@mellanox.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44720 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750879AbcEINo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 09:44:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset enables use of the slab/kmem_cache bulk alloc API, and
completes the use the slab/kmem_cache bulking API in the network stack.

I've not included the patches that introduce a SKB bulk hint, which
would beneficial for drivers like mlx5.  Lets see if we can agree on
this patchset first.

---

Jesper Dangaard Brouer (3):
      net: bulk alloc and reuse of SKBs in NAPI context
      mlx4: use napi_alloc_skb API to get SKB bulk allocations
      net: warn on napi_alloc_skb being called in wrong context


 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    7 ++-
 net/core/skbuff.c                          |   74 ++++++++++++++++++----------
 2 files changed, 52 insertions(+), 29 deletions(-)
