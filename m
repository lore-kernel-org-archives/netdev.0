From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] qlogic: qed: fix error codes in qed_resc_alloc()
Date: Thu, 5 Nov 2015 11:41:28 +0300
Message-ID: <20151105084128.GC19405@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ariel Elior <Ariel.Elior@qlogic.com>, everest-linux-l2@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We accidentally return success instead of -ENOMEM here.

Fixes: fe56b9e6a8d9 ('qed: Add module with basic common support')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/qlogic/qed/qed_dev.c b/drivers/net/ethernet/qlogic/qed/qed_dev.c
index b9b7b7e..562e160 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_dev.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_dev.c
@@ -223,6 +223,7 @@ int qed_resc_alloc(struct qed_dev *cdev)
 		if (!p_hwfn->p_tx_cids) {
 			DP_NOTICE(p_hwfn,
 				  "Failed to allocate memory for Tx Cids\n");
+			rc = -ENOMEM;
 			goto alloc_err;
 		}
 
@@ -230,6 +231,7 @@ int qed_resc_alloc(struct qed_dev *cdev)
 		if (!p_hwfn->p_rx_cids) {
 			DP_NOTICE(p_hwfn,
 				  "Failed to allocate memory for Rx Cids\n");
+			rc = -ENOMEM;
 			goto alloc_err;
 		}
 	}
@@ -281,14 +283,17 @@ int qed_resc_alloc(struct qed_dev *cdev)
 
 		/* EQ */
 		p_eq = qed_eq_alloc(p_hwfn, 256);
-
-		if (!p_eq)
+		if (!p_eq) {
+			rc = -ENOMEM;
 			goto alloc_err;
+		}
 		p_hwfn->p_eq = p_eq;
 
 		p_consq = qed_consq_alloc(p_hwfn);
-		if (!p_consq)
+		if (!p_consq) {
+			rc = -ENOMEM;
 			goto alloc_err;
+		}
 		p_hwfn->p_consq = p_consq;
 
 		/* DMA info initialization */
@@ -303,6 +308,7 @@ int qed_resc_alloc(struct qed_dev *cdev)
 	cdev->reset_stats = kzalloc(sizeof(*cdev->reset_stats), GFP_KERNEL);
 	if (!cdev->reset_stats) {
 		DP_NOTICE(cdev, "Failed to allocate reset statistics\n");
+		rc = -ENOMEM;
 		goto alloc_err;
 	}
 
