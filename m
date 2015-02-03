From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 5/7] net/mlx4_en: Print page allocator information
Date: Tue,  3 Feb 2015 17:57:19 +0200
Message-ID: <1422979041-25208-6-git-send-email-amirv@mellanox.com>
References: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40296 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S966308AbbBCP6X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Feb 2015 10:58:23 -0500
In-Reply-To: <1422979041-25208-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

After Initialization of page_alloc, print actual allocated page
size and number of frags it contains. prints is done only when drv
message level is set on the interface.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 2ba5d36..30a2203 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -162,6 +162,10 @@ static int mlx4_en_init_allocator(struct mlx4_en_priv *priv,
 		if (mlx4_alloc_pages(priv, &ring->page_alloc[i],
 				     frag_info, GFP_KERNEL | __GFP_COLD))
 			goto out;
+
+		en_dbg(DRV, priv, "  frag %d allocator: - size:%d frags:%d\n",
+		       i, ring->page_alloc[i].page_size,
+		       atomic_read(&ring->page_alloc[i].page->_count));
 	}
 	return 0;
 
-- 
1.9.3
