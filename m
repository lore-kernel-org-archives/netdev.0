From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: stmmac: fix a broken u32 less than zero check
Date: Tue,  6 Jun 2017 14:10:49 +0100
Message-ID: <20170606131049.26887-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:47594 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751305AbdFFNKw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 09:10:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The check that queue is less or equal to zero is always true
because queue is a u32; queue is decremented and will wrap around
and never go -ve. Fix this by making queue an int.

Detected by CoverityScan, CID#1428988 ("Unsigned compared against 0")

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 68a188e74c54..05b1ec9194da 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -1207,7 +1207,7 @@ static int init_dma_rx_desc_rings(struct net_device *dev, gfp_t flags)
 	u32 rx_count = priv->plat->rx_queues_to_use;
 	unsigned int bfsize = 0;
 	int ret = -ENOMEM;
-	u32 queue;
+	int queue;
 	int i;
 
 	if (priv->hw->mode->set_16kib_bfsize)
-- 
2.11.0
