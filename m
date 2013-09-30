From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 1/3] net: calxedaxgmac: fix clearing of old filter addresses
Date: Mon, 30 Sep 2013 15:12:15 -0500
Message-ID: <1380571937-23439-2-git-send-email-robherring2@gmail.com>
References: <1380571937-23439-1-git-send-email-robherring2@gmail.com>
Cc: Rob Herring <rob.herring@calxeda.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380571937-23439-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

In commit 2ee68f621af280 (net: calxedaxgmac: fix various errors in
xgmac_set_rx_mode), a fix to clean-up old address entries was added.
However, the loop to zero out the entries failed to increment the register
address resulting in only 1 entry getting cleared. Fix this to correctly
use the loop index. Also, the end of the loop condition was off by 1 and
should have been <= rather than <.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 78d6d6b..94358d2 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1342,8 +1342,8 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 	}
 
 out:
-	for (i = reg; i < XGMAC_MAX_FILTER_ADDR; i++)
-		xgmac_set_mac_addr(ioaddr, NULL, reg);
+	for (i = reg; i <= XGMAC_MAX_FILTER_ADDR; i++)
+		xgmac_set_mac_addr(ioaddr, NULL, i);
 	for (i = 0; i < XGMAC_NUM_HASH; i++)
 		writel(hash_filter[i], ioaddr + XGMAC_HASH(i));
 
-- 
1.8.1.2
