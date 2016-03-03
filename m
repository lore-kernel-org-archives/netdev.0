From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net/ethoc: do not free array priv->mdio->irq
Date: Thu,  3 Mar 2016 13:43:34 +0000
Message-ID: <1457012614-19564-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Tobias Klauser <tklauser@distanz.ch>,
	Fabian Frederick <fabf@skynet.be>,
	Max Filippov <jcmvbkbc@gmail.com>, netdev@vger.kernel.org
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
 drivers/net/ethernet/ethoc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 62fa136..41b0106 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1265,7 +1265,6 @@ static int ethoc_remove(struct platform_device *pdev)
 
 		if (priv->mdio) {
 			mdiobus_unregister(priv->mdio);
-			kfree(priv->mdio->irq);
 			mdiobus_free(priv->mdio);
 		}
 		if (priv->clk)
-- 
2.7.0
