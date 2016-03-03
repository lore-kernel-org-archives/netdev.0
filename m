From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: eth: altera: do not free array priv->mdio->irq
Date: Thu,  3 Mar 2016 13:47:18 +0000
Message-ID: <1457012838-19743-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Vince Bridgers <vbridger@opensource.altera.com>,
	netdev@vger.kernel.org, nios2-dev@lists.rocketboards.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

priv->mdio->irq used to be allocated and required freeing, but it
is now a fixed sized array and should no longer be free'd.

Issue detected using static analysis with CoverityScan

Fixes: e7f4dc3536a400 ("mdio: Move allocation of interrupts into core")
Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 1747285..f749e4d 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -193,7 +193,6 @@ static void altera_tse_mdio_destroy(struct net_device *dev)
 			    priv->mdio->id);
 
 	mdiobus_unregister(priv->mdio);
-	kfree(priv->mdio->irq);
 	mdiobus_free(priv->mdio);
 	priv->mdio = NULL;
 }
-- 
2.7.0
