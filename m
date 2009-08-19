From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/3] qlge: Remove unused workers and irq handler.
Date: Wed, 19 Aug 2009 16:53:11 -0700
Message-ID: <1250725991-7155-4-git-send-email-ron.mercer@qlogic.com>
References: <1250725991-7155-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:23652 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753575AbZHSX6u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 19:58:50 -0400
In-Reply-To: <1250725991-7155-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    2 --
 drivers/net/qlge/qlge_main.c |   32 --------------------------------
 2 files changed, 0 insertions(+), 34 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 9e30fb0..ac14f1b 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1292,7 +1292,6 @@ struct rx_ring {
 	u32 cpu;		/* Which CPU this should run on. */
 	char name[IFNAMSIZ + 5];
 	struct napi_struct napi;
-	struct delayed_work rx_work;
 	u8 reserved;
 	struct ql_adapter *qdev;
 };
@@ -1516,7 +1515,6 @@ struct ql_adapter {
 	union flash_params flash;
 
 	struct net_device_stats stats;
-	struct workqueue_struct *q_workqueue;
 	struct workqueue_struct *workqueue;
 	struct delayed_work asic_reset_work;
 	struct delayed_work mpi_reset_work;
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 56b5d0e..b814c4d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1945,38 +1945,6 @@ static void ql_vlan_rx_kill_vid(struct net_device *ndev, u16 vid)
 
 }
 
-/* Worker thread to process a given rx_ring that is dedicated
- * to outbound completions.
- */
-static void ql_tx_clean(struct work_struct *work)
-{
-	struct rx_ring *rx_ring =
-	    container_of(work, struct rx_ring, rx_work.work);
-	ql_clean_outbound_rx_ring(rx_ring);
-	ql_enable_completion_interrupt(rx_ring->qdev, rx_ring->irq);
-
-}
-
-/* Worker thread to process a given rx_ring that is dedicated
- * to inbound completions.
- */
-static void ql_rx_clean(struct work_struct *work)
-{
-	struct rx_ring *rx_ring =
-	    container_of(work, struct rx_ring, rx_work.work);
-	ql_clean_inbound_rx_ring(rx_ring, 64);
-	ql_enable_completion_interrupt(rx_ring->qdev, rx_ring->irq);
-}
-
-/* MSI-X Multiple Vector Interrupt Handler for outbound completions. */
-static irqreturn_t qlge_msix_tx_isr(int irq, void *dev_id)
-{
-	struct rx_ring *rx_ring = dev_id;
-	queue_delayed_work_on(rx_ring->cpu, rx_ring->qdev->q_workqueue,
-			      &rx_ring->rx_work, 0);
-	return IRQ_HANDLED;
-}
-
 /* MSI-X Multiple Vector Interrupt Handler for inbound completions. */
 static irqreturn_t qlge_msix_dflt_rx_isr(int irq, void *dev_id)
 {
-- 
1.6.0.2

