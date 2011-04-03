From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next-2.6 1/2] be2net: Rename some struct members for clarity
Date: Sun, 3 Apr 2011 17:24:11 +0530
Message-ID: <71102a3a-3920-4b00-92f3-84228ed1c79a@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	"Sarveswara Rao Mygapula" <sarveswararao.mygapula@emulex.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:1957 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752046Ab1DCLyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 07:54:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Renamed msix_vec_idx to eq_idx in be_eq_obj struct.
Renamed msix_vec_next_idx to eq_next_idx in be_adapter structure.
These members are used in INTX mode also.

Signed-off-by: Sarveswara Rao Mygapula <sarveswararao.mygapula@emulex.com>
Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/benet/be.h      |    4 ++--
 drivers/net/benet/be_main.c |   10 +++++-----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 3937bca..29f1210 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -155,7 +155,7 @@ struct be_eq_obj {
 	u16 min_eqd;		/* in usecs */
 	u16 max_eqd;		/* in usecs */
 	u16 cur_eqd;		/* in usecs */
-	u8  msix_vec_idx;
+	u8  eq_idx;
 
 	struct napi_struct napi;
 };
@@ -292,7 +292,7 @@ struct be_adapter {
 	u32 num_rx_qs;
 	u32 big_page_size;	/* Compounded page size shared by rx wrbs */
 
-	u8 msix_vec_next_idx;
+	u8 eq_next_idx;
 	struct be_drv_stats drv_stats;
 
 	struct vlan_group *vlan_grp;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index a24fb45..351c1f2 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1509,7 +1509,7 @@ static int be_tx_queues_create(struct be_adapter *adapter)
 	if (be_cmd_eq_create(adapter, eq, adapter->tx_eq.cur_eqd))
 		goto tx_eq_free;
 
-	adapter->tx_eq.msix_vec_idx = adapter->msix_vec_next_idx++;
+	adapter->tx_eq.eq_idx = adapter->eq_next_idx++;
 
 
 	/* Alloc TX eth compl queue */
@@ -1621,7 +1621,7 @@ static int be_rx_queues_create(struct be_adapter *adapter)
 		if (rc)
 			goto err;
 
-		rxo->rx_eq.msix_vec_idx = adapter->msix_vec_next_idx++;
+		rxo->rx_eq.eq_idx = adapter->eq_next_idx++;
 
 		/* CQ */
 		cq = &rxo->cq;
@@ -1697,11 +1697,11 @@ static irqreturn_t be_intx(int irq, void *dev)
 		if (!isr)
 			return IRQ_NONE;
 
-		if ((1 << adapter->tx_eq.msix_vec_idx & isr))
+		if ((1 << adapter->tx_eq.eq_idx & isr))
 			event_handle(adapter, &adapter->tx_eq);
 
 		for_all_rx_queues(adapter, rxo, i) {
-			if ((1 << rxo->rx_eq.msix_vec_idx & isr))
+			if ((1 << rxo->rx_eq.eq_idx & isr))
 				event_handle(adapter, &rxo->rx_eq);
 		}
 	}
@@ -1964,7 +1964,7 @@ static void be_sriov_disable(struct be_adapter *adapter)
 static inline int be_msix_vec_get(struct be_adapter *adapter,
 					struct be_eq_obj *eq_obj)
 {
-	return adapter->msix_entries[eq_obj->msix_vec_idx].vector;
+	return adapter->msix_entries[eq_obj->eq_idx].vector;
 }
 
 static int be_request_irq(struct be_adapter *adapter,
-- 
1.6.0.2

