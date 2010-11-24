From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next] bnx2x: Do interrupt mode initialization and
 NAPIs adding before register_netdev()
Date: Wed, 24 Nov 2010 17:21:18 +0200
Message-ID: <1290612078.27220.2.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>, mchan@broadcom.com
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4193 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750707Ab0KXPVb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Nov 2010 10:21:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the interrupt mode configuration and NAPIs adding before a
register_netdev() call to prevent netdev->open() from running
before these functions are done.

Advance a driver version number.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
Reported-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |    4 ++--
 drivers/net/bnx2x/bnx2x_main.c |   12 ++++++------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 863e73a..342ab58 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -20,8 +20,8 @@
  * (you will need to reboot afterwards) */
 /* #define BNX2X_STOP_ON_ERROR */
 
-#define DRV_MODULE_VERSION      "1.60.00-4"
-#define DRV_MODULE_RELDATE      "2010/11/01"
+#define DRV_MODULE_VERSION      "1.60.00-5"
+#define DRV_MODULE_RELDATE      "2010/11/24"
 #define BNX2X_BC_VER            0x040200
 
 #define BNX2X_MULTI_QUEUE
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 92057d7..f53edfd 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -9096,12 +9096,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	/* calc qm_cid_count */
 	bp->qm_cid_count = bnx2x_set_qm_cid_count(bp, cid_count);
 
-	rc = register_netdev(dev);
-	if (rc) {
-		dev_err(&pdev->dev, "Cannot register net device\n");
-		goto init_one_exit;
-	}
-
 	/* Configure interupt mode: try to enable MSI-X/MSI if
 	 * needed, set bp->num_queues appropriately.
 	 */
@@ -9110,6 +9104,12 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 	/* Add all NAPI objects */
 	bnx2x_add_all_napi(bp);
 
+	rc = register_netdev(dev);
+	if (rc) {
+		dev_err(&pdev->dev, "Cannot register net device\n");
+		goto init_one_exit;
+	}
+
 	bnx2x_get_pcie_width_speed(bp, &pcie_width, &pcie_speed);
 
 	netdev_info(dev, "%s (%c%d) PCI-E x%d %s found at mem %lx,"
-- 
1.7.0.4




