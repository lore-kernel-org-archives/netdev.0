From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 16/17] fm10k: use snprintf() instead of sprintf() to avoid buffer overflow
Date: Mon, 12 Oct 2015 22:53:17 -0700
Message-ID: <1444715598-20970-17-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:62687 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040AbbJMFx3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 01:53:29 -0400
In-Reply-To: <1444715598-20970-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c | 6 +++---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 8 ++++----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c b/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
index 08ecf43..5304bc1 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_debugfs.c
@@ -176,7 +176,7 @@ void fm10k_dbg_q_vector_init(struct fm10k_q_vector *q_vector)
 		return;
 
 	/* Generate a folder for each q_vector */
-	sprintf(name, "q_vector.%03d", q_vector->v_idx);
+	snprintf(name, sizeof(name), "q_vector.%03d", q_vector->v_idx);
 
 	q_vector->dbg_q_vector = debugfs_create_dir(name, interface->dbg_intfc);
 	if (!q_vector->dbg_q_vector)
@@ -186,7 +186,7 @@ void fm10k_dbg_q_vector_init(struct fm10k_q_vector *q_vector)
 	for (i = 0; i < q_vector->tx.count; i++) {
 		struct fm10k_ring *ring = &q_vector->tx.ring[i];
 
-		sprintf(name, "tx_ring.%03d", ring->queue_index);
+		snprintf(name, sizeof(name), "tx_ring.%03d", ring->queue_index);
 
 		debugfs_create_file(name, 0600,
 				    q_vector->dbg_q_vector, ring,
@@ -197,7 +197,7 @@ void fm10k_dbg_q_vector_init(struct fm10k_q_vector *q_vector)
 	for (i = 0; i < q_vector->rx.count; i++) {
 		struct fm10k_ring *ring = &q_vector->rx.ring[i];
 
-		sprintf(name, "rx_ring.%03d", ring->queue_index);
+		snprintf(name, sizeof(name), "rx_ring.%03d", ring->queue_index);
 
 		debugfs_create_file(name, 0600,
 				    q_vector->dbg_q_vector, ring,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 4ef2fbd..447a5f8 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -206,13 +206,13 @@ static void fm10k_get_stat_strings(struct net_device *dev, u8 *data)
 	}
 
 	for (i = 0; i < interface->hw.mac.max_queues; i++) {
-		sprintf(p, "tx_queue_%u_packets", i);
+		snprintf(p, ETH_GSTRING_LEN, "tx_queue_%u_packets", i);
 		p += ETH_GSTRING_LEN;
-		sprintf(p, "tx_queue_%u_bytes", i);
+		snprintf(p, ETH_GSTRING_LEN, "tx_queue_%u_bytes", i);
 		p += ETH_GSTRING_LEN;
-		sprintf(p, "rx_queue_%u_packets", i);
+		snprintf(p, ETH_GSTRING_LEN, "rx_queue_%u_packets", i);
 		p += ETH_GSTRING_LEN;
-		sprintf(p, "rx_queue_%u_bytes", i);
+		snprintf(p, ETH_GSTRING_LEN, "rx_queue_%u_bytes", i);
 		p += ETH_GSTRING_LEN;
 	}
 }
-- 
2.4.3
