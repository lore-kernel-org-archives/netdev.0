From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net V1 0/2] net/mlx4_en: Fix pages never dma unmapped on rx
Date: Mon,  7 Oct 2013 13:38:11 +0200
Message-ID: <1381145893-20930-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53106 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751369Ab3JGLio (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Oct 2013 07:38:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes a bug introduced by commit 51151a16 (mlx4: allow order-0
memory allocations in RX path). Where dma_unmap_page wasn't called.

Changes from V0:
- Added "Rename name of mlx4_en_rx_alloc members". Old names were confusing.
- Last frag in page calculation was wrong. Since all frags in page are of the
  same size, need to add this frag_stride to end of frag offset, and not the
  size of next frag in skb.

Amir Vadai (2):
  net/mlx4_en: Rename name of mlx4_en_rx_alloc members
  net/mlx4_en: Fix pages never dma unmapped on rx

 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 41 ++++++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  4 +--
 2 files changed, 26 insertions(+), 19 deletions(-)

-- 
1.8.3.4
