From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 14/17] fm10k: use macro for default Tx and Rx ITR values
Date: Thu,  3 Dec 2015 16:29:51 -0800
Message-ID: <1449188994-64940-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5708 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754297AbbLDA37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:29:59 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h         | 2 ++
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 4 ++--
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 4 ++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index bb799b3..115033f 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -175,6 +175,8 @@ struct fm10k_ring_container {
 
 #define ITR_IS_ADAPTIVE(itr) (!!(itr & FM10K_ITR_ADAPTIVE))
 
+#define FM10K_TX_ITR_DEFAULT	FM10K_ITR_10K
+#define FM10K_RX_ITR_DEFAULT	FM10K_ITR_20K
 #define FM10K_ITR_ENABLE	(FM10K_ITR_AUTOMASK | FM10K_ITR_MASK_CLEAR)
 
 static inline struct netdev_queue *txring_txq(const struct fm10k_ring *ring)
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index a505a50..109e211 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -729,10 +729,10 @@ static int fm10k_set_coalesce(struct net_device *dev,
 
 	/* set initial values for adaptive ITR */
 	if (ec->use_adaptive_tx_coalesce)
-		tx_itr = FM10K_ITR_ADAPTIVE | FM10K_ITR_10K;
+		tx_itr = FM10K_ITR_ADAPTIVE | FM10K_TX_ITR_DEFAULT;
 
 	if (ec->use_adaptive_rx_coalesce)
-		rx_itr = FM10K_ITR_ADAPTIVE | FM10K_ITR_20K;
+		rx_itr = FM10K_ITR_ADAPTIVE | FM10K_RX_ITR_DEFAULT;
 
 	/* update interface */
 	interface->tx_itr = tx_itr;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index 1f0d9bc..0cdb79e8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -1771,8 +1771,8 @@ static int fm10k_sw_init(struct fm10k_intfc *interface,
 	interface->rx_ring_count = FM10K_DEFAULT_RXD;
 
 	/* set default interrupt moderation */
-	interface->tx_itr = FM10K_ITR_10K;
-	interface->rx_itr = FM10K_ITR_ADAPTIVE | FM10K_ITR_20K;
+	interface->tx_itr = FM10K_TX_ITR_DEFAULT;
+	interface->rx_itr = FM10K_ITR_ADAPTIVE | FM10K_RX_ITR_DEFAULT;
 
 	/* initialize vxlan_port list */
 	INIT_LIST_HEAD(&interface->vxlan_port);
-- 
2.5.0
