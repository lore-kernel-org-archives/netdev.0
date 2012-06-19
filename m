From: "Merav Sicron" <meravs@broadcom.com>
Subject: [net-next patch 8/11 v2] bnx2x: Allow up to 63 RSS queues
Date: Tue, 19 Jun 2012 20:48:29 +0300
Message-ID: <1340128112-22935-9-git-send-email-meravs@broadcom.com>
References: <1340128112-22935-1-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Merav Sicron" <meravs@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net, eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4359 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754470Ab2FSOl0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 10:41:26 -0400
In-Reply-To: <1340128112-22935-1-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removed the limitation in the code for 16 RSS queues.

Signed-off-by: Merav Sicron <meravs@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   13 +++----------
 1 file changed, 3 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 2d67856..7571c8c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11813,13 +11813,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	max_non_def_sbs = bnx2x_get_num_non_def_sbs(pdev);
 
-	/* !!! FIXME !!!
-	 * Do not allow the maximum SB count to grow above 16
-	 * since Special CIDs starts from 16*BNX2X_MULTI_TX_COS=48.
-	 * We will use the FP_SB_MAX_E1x macro for this matter.
-	 */
-	max_non_def_sbs = min_t(int, FP_SB_MAX_E1x, max_non_def_sbs);
-
 	WARN_ON(!max_non_def_sbs);
 
 	/* Maximum number of RSS queues: one IGU SB goes to CNIC */
@@ -11841,9 +11834,6 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	bp = netdev_priv(dev);
 
-	BNX2X_DEV_INFO("Allocated netdev with %d tx and %d rx queues\n",
-			  tx_count, rx_count);
-
 	bp->igu_sb_cnt = max_non_def_sbs;
 	bp->msg_enable = debug;
 	pci_set_drvdata(pdev, dev);
@@ -11856,6 +11846,9 @@ static int __devinit bnx2x_init_one(struct pci_dev *pdev,
 
 	BNX2X_DEV_INFO("max_non_def_sbs %d\n", max_non_def_sbs);
 
+	BNX2X_DEV_INFO("Allocated netdev with %d tx and %d rx queues\n",
+			  tx_count, rx_count);
+
 	rc = bnx2x_init_bp(bp);
 	if (rc)
 		goto init_one_exit;
-- 
1.7.10
