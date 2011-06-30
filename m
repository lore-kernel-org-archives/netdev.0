From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/3] qlge: Fix printk priority so chip fatal errors are always reported.
Date: Thu, 30 Jun 2011 13:02:06 -0700
Message-ID: <1309464127-14797-2-git-send-email-ron.mercer@qlogic.com>
References: <1308855049.6688.19.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<jitendra.kalsaria@qlogic.com>, <ameen.rahman@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe005.messaging.microsoft.com ([216.32.181.185]:1275
	"EHLO CH1EHSOBE015.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751097Ab1F3UTu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 16:19:50 -0400
In-Reply-To: <1308855049.6688.19.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Precedence of the printk should be at higher level so chip fatal
errors are always reported.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   22 +++++++++-------------
 1 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 4fbefcf..6b4ff97 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2170,23 +2170,20 @@ static void ql_process_chip_ae_intr(struct ql_adapter *qdev,
 		return;
 
 	case CAM_LOOKUP_ERR_EVENT:
-		netif_err(qdev, link, qdev->ndev,
-			  "Multiple CAM hits lookup occurred.\n");
-		netif_err(qdev, drv, qdev->ndev,
-			  "This event shouldn't occur.\n");
+		netdev_err(qdev->ndev, "Multiple CAM hits lookup occurred.\n");
+		netdev_err(qdev->ndev, "This event shouldn't occur.\n");
 		ql_queue_asic_error(qdev);
 		return;
 
 	case SOFT_ECC_ERROR_EVENT:
-		netif_err(qdev, rx_err, qdev->ndev,
-			  "Soft ECC error detected.\n");
+		netdev_err(qdev->ndev, "Soft ECC error detected.\n");
 		ql_queue_asic_error(qdev);
 		break;
 
 	case PCI_ERR_ANON_BUF_RD:
-		netif_err(qdev, rx_err, qdev->ndev,
-			  "PCI error occurred when reading anonymous buffers from rx_ring %d.\n",
-			  ib_ae_rsp->q_id);
+		netdev_err(qdev->ndev, "PCI error occurred when reading "
+					"anonymous buffers from rx_ring %d.\n",
+					ib_ae_rsp->q_id);
 		ql_queue_asic_error(qdev);
 		break;
 
@@ -2441,11 +2438,10 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	 */
 	if (var & STS_FE) {
 		ql_queue_asic_error(qdev);
-		netif_err(qdev, intr, qdev->ndev,
-			  "Got fatal error, STS = %x.\n", var);
+		netdev_err(qdev->ndev, "Got fatal error, STS = %x.\n", var);
 		var = ql_read32(qdev, ERR_STS);
-		netif_err(qdev, intr, qdev->ndev,
-			  "Resetting chip. Error Status Register = 0x%x\n", var);
+		netdev_err(qdev->ndev, "Resetting chip. "
+					"Error Status Register = 0x%x\n", var);
 		return IRQ_HANDLED;
 	}
 
-- 
1.6.0.2


