From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [net-next PATCH 00/11] net: mitigating kmem_cache slowpath and BoF
 discussion patches
Date: Tue, 02 Feb 2016 22:11:28 +0100
Message-ID: <20160202211051.16315.51808.stgit@firesoul>
References: <20151023124451.17364.14594.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Christoph Lameter <cl@linux.com>, tom@herbertland.com,
	Alexander Duyck <alexander.duyck@gmail.com>,
	alexei.starovoitov@gmail.com,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	ogerlitz@mellanox.com, gerlitz.or@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39322 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932929AbcBBVLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 16:11:30 -0500
In-Reply-To: <20151023124451.17364.14594.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset is relevant for my NetDev 1.1 "Network Performance BoF" [1].

The first 4 patches, is a repost[2], for the first real use-case of
kmem_cache bulk alloc and free API.  They were adjusted slightly to
accomodate my last slab API changes.  They should be ready for
inclusion in net-next, as the needed MM tree are avail in net-next.

Patch 5 is also enabling the SKB bulk API for mlx5.

Thus, patches 1-5 should be ready for net-next.

After patch 5, the experimental patches begin, which is Prove-of-Concept
code for what we will be discussing during the Network Performance BoF [1]

[1] http://netdevconf.org/1.1/bof-network-performance-bof-jesper-dangaard-brouer.html
[2] http://thread.gmane.org/gmane.linux.network/384302/

---

Jesper Dangaard Brouer (11):
      net: bulk free infrastructure for NAPI context, use napi_consume_skb
      net: bulk free SKBs that were delay free'ed due to IRQ context
      ixgbe: bulk free SKBs during TX completion cleanup cycle
      net: bulk alloc and reuse of SKBs in NAPI context
      mlx5: use napi_*_skb APIs to get bulk alloc and free
      mlx5: RX bulking or bundling of packets before calling network stack
      net: introduce napi_alloc_skb_bulk() for more use-cases
      mlx5: hint the NAPI alloc skb API about the expected bulk size
      EXPERIMENT: dummy: bulk free
      net: API for RX handover of multiple SKBs to stack
      net: RPS bulk enqueue to backlog


 drivers/net/dummy.c                               |    3 
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    6 -
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |    5 -
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   24 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |    4 -
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c |    4 -
 include/linux/netdevice.h                         |   13 ++
 include/linux/skbuff.h                            |   23 ++-
 net/core/dev.c                                    |  160 ++++++++++++++++++++-
 net/core/skbuff.c                                 |  122 +++++++++++++++-
 10 files changed, 327 insertions(+), 37 deletions(-)
