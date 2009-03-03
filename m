From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/8] qlge: Clean up link up processing.
Date: Tue,  3 Mar 2009 14:10:32 -0800
Message-ID: <1236118237-14483-4-git-send-email-ron.mercer@qlogic.com>
References: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50781 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761763AbZCCWNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 17:13:53 -0500
In-Reply-To: <1236118237-14483-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_mpi.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 5871bc9..3b4b494 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -159,24 +159,23 @@ static int ql_idc_cmplt_aen(struct ql_adapter *qdev)
 
 	return status;
 }
+
 static void ql_link_up(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
+	int status;
 	mbcp->out_count = 2;
 
-	if (ql_get_mb_sts(qdev, mbcp))
-		goto exit;
+	status = ql_get_mb_sts(qdev, mbcp);
+	if (status) {
+		QPRINTK(qdev, DRV, ERR,
+			"%s: Could not get mailbox status.\n", __func__);
+		return;
+	}
 
 	qdev->link_status = mbcp->mbox_out[1];
 	QPRINTK(qdev, DRV, ERR, "Link Up.\n");
-	QPRINTK(qdev, DRV, INFO, "Link Status = 0x%.08x.\n", mbcp->mbox_out[1]);
-	if (!netif_carrier_ok(qdev->ndev)) {
-		QPRINTK(qdev, LINK, INFO, "Link is Up.\n");
-		netif_carrier_on(qdev->ndev);
-		netif_wake_queue(qdev->ndev);
-	}
-exit:
-	/* Clear the MPI firmware status. */
-	ql_write32(qdev, CSR, CSR_CMD_CLR_R2PCI_INT);
+
+	netif_carrier_on(qdev->ndev);
 }
 
 static void ql_link_down(struct ql_adapter *qdev, struct mbox_params *mbcp)
-- 
1.6.0.2

