From: Rob Herring <robherring2@gmail.com>
Subject: [PATCH 2/3] net: calxedaxgmac: add uc and mc filter addresses in promiscuous mode
Date: Mon, 30 Sep 2013 15:12:16 -0500
Message-ID: <1380571937-23439-3-git-send-email-robherring2@gmail.com>
References: <1380571937-23439-1-git-send-email-robherring2@gmail.com>
Cc: Rob Herring <rob.herring@calxeda.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1380571937-23439-1-git-send-email-robherring2@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <rob.herring@calxeda.com>

Even in promiscuous mode, we need to add filter addresses for correct
operation. This fixes silent failures when using a bridge and adding
addresses using the "bridge fdb add" command.

Signed-off-by: Rob Herring <rob.herring@calxeda.com>
---
 drivers/net/ethernet/calxeda/xgmac.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/calxeda/xgmac.c b/drivers/net/ethernet/calxeda/xgmac.c
index 94358d2..35da09b 100644
--- a/drivers/net/ethernet/calxeda/xgmac.c
+++ b/drivers/net/ethernet/calxeda/xgmac.c
@@ -1291,10 +1291,8 @@ static void xgmac_set_rx_mode(struct net_device *dev)
 	netdev_dbg(priv->dev, "# mcasts %d, # unicast %d\n",
 		 netdev_mc_count(dev), netdev_uc_count(dev));
 
-	if (dev->flags & IFF_PROMISC) {
-		writel(XGMAC_FRAME_FILTER_PR, ioaddr + XGMAC_FRAME_FILTER);
-		return;
-	}
+	if (dev->flags & IFF_PROMISC)
+		value |= XGMAC_FRAME_FILTER_PR;
 
 	memset(hash_filter, 0, sizeof(hash_filter));
 
-- 
1.8.1.2
