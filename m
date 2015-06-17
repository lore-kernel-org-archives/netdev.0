From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net-next 2/3] bna: make pointers to read-only inputs const
Date: Wed, 17 Jun 2015 18:41:57 +0200
Message-ID: <1434559318-31070-3-git-send-email-ivecera@redhat.com>
References: <1434559318-31070-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60957 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753033AbbFQQlY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Jun 2015 12:41:24 -0400
In-Reply-To: <1434559318-31070-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna.h       | 19 +++++++++----------
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 14 +++++++-------
 drivers/net/ethernet/brocade/bna/bnad.c      |  6 +++---
 drivers/net/ethernet/brocade/bna/bnad.h      |  2 +-
 4 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna.h b/drivers/net/ethernet/brocade/bna/bna.h
index dc845b2..006dcad 100644
--- a/drivers/net/ethernet/brocade/bna/bna.h
+++ b/drivers/net/ethernet/brocade/bna/bna.h
@@ -243,7 +243,7 @@ do {									\
 
 /*  Inline functions  */
 
-static inline struct bna_mac *bna_mac_find(struct list_head *q, u8 *addr)
+static inline struct bna_mac *bna_mac_find(struct list_head *q, const u8 *addr)
 {
 	struct bna_mac *mac;
 
@@ -362,15 +362,14 @@ void bna_rx_cleanup_complete(struct bna_rx *rx);
 void bna_rx_coalescing_timeo_set(struct bna_rx *rx, int coalescing_timeo);
 void bna_rx_dim_reconfig(struct bna *bna, const u32 vector[][BNA_BIAS_T_MAX]);
 void bna_rx_dim_update(struct bna_ccb *ccb);
-enum bna_cb_status
-bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac);
-enum bna_cb_status
-bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist);
-enum bna_cb_status
-bna_rx_mcast_add(struct bna_rx *rx, u8 *mcmac,
-		 void (*cbfn)(struct bnad *, struct bna_rx *));
-enum bna_cb_status
-bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mcmac);
+enum bna_cb_status bna_rx_ucast_set(struct bna_rx *rx, const u8 *ucmac);
+enum bna_cb_status bna_rx_ucast_listset(struct bna_rx *rx, int count,
+					const u8 *uclist);
+enum bna_cb_status bna_rx_mcast_add(struct bna_rx *rx, const u8 *mcmac,
+				    void (*cbfn)(struct bnad *,
+						 struct bna_rx *));
+enum bna_cb_status bna_rx_mcast_listset(struct bna_rx *rx, int count,
+					const u8 *mcmac);
 void
 bna_rx_mcast_delall(struct bna_rx *rx);
 enum bna_cb_status
diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 64eb8c4..33f5e55 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -353,7 +353,7 @@ bna_bfi_rss_enable(struct bna_rxf *rxf)
 
 /* This function gets the multicast MAC that has already been added to CAM */
 static struct bna_mac *
-bna_rxf_mcmac_get(struct bna_rxf *rxf, u8 *mac_addr)
+bna_rxf_mcmac_get(struct bna_rxf *rxf, const u8 *mac_addr)
 {
 	struct bna_mac *mac;
 
@@ -729,7 +729,7 @@ bna_rxf_fail(struct bna_rxf *rxf)
 }
 
 enum bna_cb_status
-bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac)
+bna_rx_ucast_set(struct bna_rx *rx, const u8 *ucmac)
 {
 	struct bna_rxf *rxf = &rx->rxf;
 
@@ -751,7 +751,7 @@ bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac)
 }
 
 enum bna_cb_status
-bna_rx_mcast_add(struct bna_rx *rx, u8 *addr,
+bna_rx_mcast_add(struct bna_rx *rx, const u8 *addr,
 		 void (*cbfn)(struct bnad *, struct bna_rx *))
 {
 	struct bna_rxf *rxf = &rx->rxf;
@@ -780,12 +780,12 @@ bna_rx_mcast_add(struct bna_rx *rx, u8 *addr,
 }
 
 enum bna_cb_status
-bna_rx_ucast_listset(struct bna_rx *rx, int count, u8 *uclist)
+bna_rx_ucast_listset(struct bna_rx *rx, int count, const u8 *uclist)
 {
 	struct bna_ucam_mod *ucam_mod = &rx->bna->ucam_mod;
 	struct bna_rxf *rxf = &rx->rxf;
 	struct list_head list_head;
-	u8 *mcaddr;
+	const u8 *mcaddr;
 	struct bna_mac *mac, *del_mac;
 	int i;
 
@@ -838,12 +838,12 @@ err_return:
 }
 
 enum bna_cb_status
-bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist)
+bna_rx_mcast_listset(struct bna_rx *rx, int count, const u8 *mclist)
 {
 	struct bna_mcam_mod *mcam_mod = &rx->bna->mcam_mod;
 	struct bna_rxf *rxf = &rx->rxf;
 	struct list_head list_head;
-	u8 *mcaddr;
+	const u8 *mcaddr;
 	struct bna_mac *mac, *del_mac;
 	int i;
 
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 6be31ae..85c1470 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2327,7 +2327,7 @@ bnad_rx_coalescing_timeo_set(struct bnad *bnad)
  * Called with bnad->bna_lock held
  */
 int
-bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr)
+bnad_mac_addr_set_locked(struct bnad *bnad, const u8 *mac_addr)
 {
 	int ret;
 
@@ -2356,8 +2356,8 @@ bnad_enable_default_bcast(struct bnad *bnad)
 	init_completion(&bnad->bnad_completions.mcast_comp);
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	ret = bna_rx_mcast_add(rx_info->rx, (u8 *)bnad_bcast_addr,
-				bnad_cb_rx_mcast_add);
+	ret = bna_rx_mcast_add(rx_info->rx, bnad_bcast_addr,
+			       bnad_cb_rx_mcast_add);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	if (ret == BNA_CB_SUCCESS)
diff --git a/drivers/net/ethernet/brocade/bna/bnad.h b/drivers/net/ethernet/brocade/bna/bnad.h
index 91fd82d..faedbf2 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.h
+++ b/drivers/net/ethernet/brocade/bna/bnad.h
@@ -385,7 +385,7 @@ u32 *cna_get_firmware_buf(struct pci_dev *pdev);
 /* Netdev entry point prototypes */
 void bnad_set_rx_mode(struct net_device *netdev);
 struct net_device_stats *bnad_get_netdev_stats(struct net_device *netdev);
-int bnad_mac_addr_set_locked(struct bnad *bnad, u8 *mac_addr);
+int bnad_mac_addr_set_locked(struct bnad *bnad, const u8 *mac_addr);
 int bnad_enable_default_bcast(struct bnad *bnad);
 void bnad_restore_vlans(struct bnad *bnad, u32 rx_id);
 void bnad_set_ethtool_ops(struct net_device *netdev);
-- 
2.3.6
