From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 10/24] bnx2x: removed unused variables
Date: Tue, 14 Jun 2011 14:33:34 +0300
Message-ID: <201106141433.35165.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Yaniv Rosner" <yaniv.rosner@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2495 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756299Ab1FNLe0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2011 07:34:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |    3 ---
 drivers/net/bnx2x/bnx2x_main.c |   15 ++++++---------
 2 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 2b744b0..791fb77 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -928,8 +928,6 @@ struct bnx2x {
 	bnx2x_recovery_state_t	recovery_state;
 	int			is_leader;
 	struct msix_entry	*msix_table;
-#define INT_MODE_INTx			1
-#define INT_MODE_MSI			2
 
 	int			tx_ring_size;
 
@@ -1092,7 +1090,6 @@ struct bnx2x {
 	int			multi_mode;
 	int			num_queues;
 	int			disable_tpa;
-	int			int_mode;
 	u32			*rx_indir_table;
 
 	struct tstorm_eth_mac_filter_config	mac_filters;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index c6c59ad..07feb32 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -99,6 +99,8 @@ static int disable_tpa;
 module_param(disable_tpa, int, 0);
 MODULE_PARM_DESC(disable_tpa, " Disable the TPA (LRO) feature");
 
+#define INT_MODE_INTx			1
+#define INT_MODE_MSI			2
 static int int_mode;
 module_param(int_mode, int, 0);
 MODULE_PARM_DESC(int_mode, " Force interrupt mode other then MSI-X "
@@ -6639,11 +6641,10 @@ static int bnx2x_setup_fw_client(struct bnx2x *bp,
  *
  * In case of MSI-X it will also try to enable MSI-X.
  */
-static int __devinit bnx2x_set_int_mode(struct bnx2x *bp)
+static void __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 {
-	int rc = 0;
 
-	switch (bp->int_mode) {
+	switch (int_mode) {
 	case INT_MODE_MSI:
 		bnx2x_enable_msi(bp);
 		/* falling through... */
@@ -6662,8 +6663,7 @@ static int __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 		 * so try to enable MSI-X with the requested number of fp's
 		 * and fallback to MSI or legacy INTx with one fp
 		 */
-		rc = bnx2x_enable_msix(bp);
-		if (rc) {
+		if (bnx2x_enable_msix(bp)) {
 			/* failed to enable MSI-X */
 			if (bp->multi_mode)
 				DP(NETIF_MSG_IFUP,
@@ -6674,14 +6674,12 @@ static int __devinit bnx2x_set_int_mode(struct bnx2x *bp)
 				   1 + NONE_ETH_CONTEXT_USE);
 			bp->num_queues = 1 + NONE_ETH_CONTEXT_USE;
 
+			/* Try to enable MSI */
 			if (!(bp->flags & DISABLE_MSI_FLAG))
 				bnx2x_enable_msi(bp);
 		}
-
 		break;
 	}
-
-	return rc;
 }
 
 /* must be called prioir to any HW initializations */
@@ -8725,7 +8723,6 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 					"must load devices in order!\n");
 
 	bp->multi_mode = multi_mode;
-	bp->int_mode = int_mode;
 
 	/* Set TPA flags */
 	if (disable_tpa) {
-- 
1.7.2.2


