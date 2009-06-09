From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/8] qlge: Drop inbound error frames.
Date: Tue,  9 Jun 2009 08:39:27 -0700
Message-ID: <1244561974-25662-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:58941 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbZFIPrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:47:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 0b0778d..45da405 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1518,6 +1518,13 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 		return;
 	}
 
+	/* Frame error, so drop the packet. */
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) {
+		QPRINTK(qdev, DRV, ERR, "Receive error, flags2 = 0x%x\n",
+					ib_mac_rsp->flags2);
+		dev_kfree_skb_any(skb);
+		return;
+	}
 	prefetch(skb->data);
 	skb->dev = ndev;
 	if (ib_mac_rsp->flags1 & IB_MAC_IOCB_RSP_M_MASK) {
@@ -1540,7 +1547,6 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 	 * csum or frame errors.
 	 */
 	if (qdev->rx_csum &&
-		!(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_ERR_MASK) &&
 		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK)) {
 		/* TCP frame. */
 		if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T) {
-- 
1.6.0.2

