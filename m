From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 04/21] ixgbe: add mask for 64 RSS queues
Date: Tue,  3 Jan 2017 13:07:40 -0800
Message-ID: <20170103210757.38847-5-jeffrey.t.kirsher@intel.com>
References: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3461 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S935984AbdACVIE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 16:08:04 -0500
In-Reply-To: <20170103210757.38847-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The indirection table was reported incorrectly for X550 and newer
where we can support up to 64 RSS queues.

Reported-by Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
index 15ab337..10d2967 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c
@@ -308,6 +308,7 @@ static void ixgbe_cache_ring_register(struct ixgbe_adapter *adapter)
 	ixgbe_cache_ring_rss(adapter);
 }
 
+#define IXGBE_RSS_64Q_MASK	0x3F
 #define IXGBE_RSS_16Q_MASK	0xF
 #define IXGBE_RSS_8Q_MASK	0x7
 #define IXGBE_RSS_4Q_MASK	0x3
@@ -604,6 +605,7 @@ static bool ixgbe_set_sriov_queues(struct ixgbe_adapter *adapter)
  **/
 static bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 {
+	struct ixgbe_hw *hw = &adapter->hw;
 	struct ixgbe_ring_feature *f;
 	u16 rss_i;
 
@@ -612,7 +614,11 @@ static bool ixgbe_set_rss_queues(struct ixgbe_adapter *adapter)
 	rss_i = f->limit;
 
 	f->indices = rss_i;
-	f->mask = IXGBE_RSS_16Q_MASK;
+
+	if (hw->mac.type < ixgbe_mac_X550)
+		f->mask = IXGBE_RSS_16Q_MASK;
+	else
+		f->mask = IXGBE_RSS_64Q_MASK;
 
 	/* disable ATR by default, it will be configured below */
 	adapter->flags &= ~IXGBE_FLAG_FDIR_HASH_CAPABLE;
-- 
2.9.3
