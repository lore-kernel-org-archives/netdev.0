From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 09/21] [next] qlge: Upgrade print priority for hardware event handler.
Date: Fri, 23 Jan 2009 07:16:27 -0800
Message-ID: <1232723799-8620-9-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754356AbZAWPR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:56 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These events indicate errors and should have higher
priority logging.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index f273160..f3fa375 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1553,26 +1553,27 @@ static void ql_process_chip_ae_intr(struct ql_adapter *qdev,
 {
 	switch (ib_ae_rsp->event) {
 	case MGMT_ERR_EVENT:
-		QPRINTK(qdev, RX_ERR, ERR,
+		QPRINTK(qdev, DRV, ERR,
 			"Management Processor Fatal Error.\n");
 		ql_queue_fw_error(qdev);
 		return;
 
 	case CAM_LOOKUP_ERR_EVENT:
-		QPRINTK(qdev, LINK, ERR,
+		QPRINTK(qdev, DRV, ERR,
 			"Multiple CAM hits lookup occurred.\n");
 		QPRINTK(qdev, DRV, ERR, "This event shouldn't occur.\n");
 		ql_queue_asic_error(qdev);
 		return;
 
 	case SOFT_ECC_ERROR_EVENT:
-		QPRINTK(qdev, RX_ERR, ERR, "Soft ECC error detected.\n");
+		QPRINTK(qdev, DRV, ERR, "Soft ECC error detected.\n");
 		ql_queue_asic_error(qdev);
 		break;
 
 	case PCI_ERR_ANON_BUF_RD:
-		QPRINTK(qdev, RX_ERR, ERR,
-			"PCI error occurred when reading anonymous buffers from rx_ring %d.\n",
+		QPRINTK(qdev, DRV, ERR,
+			"PCI error occurred when reading anonymous "
+			"buffers from rx_ring %d.\n",
 			ib_ae_rsp->q_id);
 		ql_queue_asic_error(qdev);
 		break;
-- 
1.6.0.2

