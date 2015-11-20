From: Saurabh Sengar <saurabh.truth@gmail.com>
Subject: [PATCH] gianfar: use of_property_read_bool()
Date: Fri, 20 Nov 2015 23:23:58 +0530
Message-ID: <1448042038-4156-1-git-send-email-saurabh.truth@gmail.com>
Cc: Saurabh Sengar <saurabh.truth@gmail.com>
To: claudiu.manoil@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

use of_property_read_bool() for testing bool property

Signed-off-by: Saurabh Sengar <saurabh.truth@gmail.com>
---
 drivers/net/ethernet/freescale/gianfar.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/ethernet/freescale/gianfar.c
index 3e6b9b4..ebeea5e 100644
--- a/drivers/net/ethernet/freescale/gianfar.c
+++ b/drivers/net/ethernet/freescale/gianfar.c
@@ -738,7 +738,6 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 	struct gfar_private *priv = NULL;
 	struct device_node *np = ofdev->dev.of_node;
 	struct device_node *child = NULL;
-	struct property *stash;
 	u32 stash_len = 0;
 	u32 stash_idx = 0;
 	unsigned int num_tx_qs, num_rx_qs;
@@ -854,9 +853,7 @@ static int gfar_of_init(struct platform_device *ofdev, struct net_device **pdev)
 			goto err_grp_init;
 	}
 
-	stash = of_find_property(np, "bd-stash", NULL);
-
-	if (stash) {
+	if (of_property_read_bool(np, "bd-stash")) {
 		priv->device_flags |= FSL_GIANFAR_DEV_HAS_BD_STASHING;
 		priv->bd_stash_en = 1;
 	}
-- 
1.9.1
