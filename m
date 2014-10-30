From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/8] net/mlx4_en: Add __GFP_COLD gfp flags in alloc_pages
Date: Thu, 30 Oct 2014 18:06:52 +0200
Message-ID: <1414685216-28907-5-git-send-email-ogerlitz@mellanox.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37974 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759269AbaJ3QHF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 12:07:05 -0400
In-Reply-To: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Needed in order to get cache cold pages (L3 flushed) for HW scatter.

Otherwise memory may flush those entries when the packet comes from
PCI, causing back pressure resulting in BW decrease.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 4cb716f..9d616a8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -54,7 +54,7 @@ static int mlx4_alloc_pages(struct mlx4_en_priv *priv,
 	dma_addr_t dma;
 
 	for (order = MLX4_EN_ALLOC_PREFER_ORDER; ;) {
-		gfp_t gfp = _gfp;
+		gfp_t gfp = _gfp | __GFP_COLD;
 
 		if (order)
 			gfp |= __GFP_COMP | __GFP_NOWARN;
-- 
1.7.1
