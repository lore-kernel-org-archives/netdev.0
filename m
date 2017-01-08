From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/8] fm10k: report the receive timestamp in FM10K_CB(skb)->tstamp
Date: Sun,  8 Jan 2017 02:10:33 -0800
Message-ID: <20170108101034.119851-8-jeffrey.t.kirsher@intel.com>
References: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60633 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1162229AbdAHKKu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 05:10:50 -0500
In-Reply-To: <20170108101034.119851-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This was accidentally removed when we defeatured the full 1588 Clock
support. We need to report the Rx descriptor timestamp value so that
applications built on top of the IES API can function properly.

Additionally, remove the FM10K_FLAG_RX_TS_ENABLED, as it is not used now
that 1588 functionality has been removed.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h      | 5 ++---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 2 ++
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 4d19e46..75d2c80 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -260,9 +260,8 @@ struct fm10k_intfc {
 #define FM10K_FLAG_RESET_REQUESTED		(u32)(BIT(0))
 #define FM10K_FLAG_RSS_FIELD_IPV4_UDP		(u32)(BIT(1))
 #define FM10K_FLAG_RSS_FIELD_IPV6_UDP		(u32)(BIT(2))
-#define FM10K_FLAG_RX_TS_ENABLED		(u32)(BIT(3))
-#define FM10K_FLAG_SWPRI_CONFIG			(u32)(BIT(4))
-#define FM10K_FLAG_DEBUG_STATS			(u32)(BIT(5))
+#define FM10K_FLAG_SWPRI_CONFIG			(u32)(BIT(3))
+#define FM10K_FLAG_DEBUG_STATS			(u32)(BIT(4))
 	int xcast_mode;
 
 	/* Tx fast path data */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 8f90c6d..5bb233a 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -475,6 +475,8 @@ static unsigned int fm10k_process_skb_fields(struct fm10k_ring *rx_ring,
 
 	fm10k_rx_checksum(rx_ring, rx_desc, skb);
 
+	FM10K_CB(skb)->tstamp = rx_desc->q.timestamp;
+
 	FM10K_CB(skb)->fi.w.vlan = rx_desc->w.vlan;
 
 	skb_record_rx_queue(skb, rx_ring->queue_index);
-- 
2.9.3
