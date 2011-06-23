From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/3] qlge:Fix printk priority so chip fatal errors are always reported.
Date: Thu, 23 Jun 2011 10:52:23 -0700
Message-ID: <1308851544-25719-2-git-send-email-ron.mercer@qlogic.com>
References: <1308851544-25719-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<jitendra.kalsaria@qlogic.com>, <ameen.rahman@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe005.messaging.microsoft.com ([216.32.180.31]:30759
	"EHLO VA3EHSOBE005.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933366Ab1FWSLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 14:11:22 -0400
In-Reply-To: <1308851544-25719-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Precedence of the printk should be at higher level so chip
	fatal errors are always reported.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 4fbefcf..66274ab 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2170,7 +2170,7 @@ static void ql_process_chip_ae_intr(struct ql_adapter *qdev,
 		return;
 
 	case CAM_LOOKUP_ERR_EVENT:
-		netif_err(qdev, link, qdev->ndev,
+		netif_err(qdev, drv, qdev->ndev,
 			  "Multiple CAM hits lookup occurred.\n");
 		netif_err(qdev, drv, qdev->ndev,
 			  "This event shouldn't occur.\n");
@@ -2178,13 +2178,13 @@ static void ql_process_chip_ae_intr(struct ql_adapter *qdev,
 		return;
 
 	case SOFT_ECC_ERROR_EVENT:
-		netif_err(qdev, rx_err, qdev->ndev,
+		netif_err(qdev, drv, qdev->ndev,
 			  "Soft ECC error detected.\n");
 		ql_queue_asic_error(qdev);
 		break;
 
 	case PCI_ERR_ANON_BUF_RD:
-		netif_err(qdev, rx_err, qdev->ndev,
+		netif_err(qdev, drv, qdev->ndev,
 			  "PCI error occurred when reading anonymous buffers from rx_ring %d.\n",
 			  ib_ae_rsp->q_id);
 		ql_queue_asic_error(qdev);
@@ -2441,10 +2441,10 @@ static irqreturn_t qlge_isr(int irq, void *dev_id)
 	 */
 	if (var & STS_FE) {
 		ql_queue_asic_error(qdev);
-		netif_err(qdev, intr, qdev->ndev,
+		netif_err(qdev, drv, qdev->ndev,
 			  "Got fatal error, STS = %x.\n", var);
 		var = ql_read32(qdev, ERR_STS);
-		netif_err(qdev, intr, qdev->ndev,
+		netif_err(qdev, drv, qdev->ndev,
 			  "Resetting chip. Error Status Register = 0x%x\n", var);
 		return IRQ_HANDLED;
 	}
-- 
1.6.0.2


