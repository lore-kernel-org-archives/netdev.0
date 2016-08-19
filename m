From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/4] ixgbevf: change hw_dbg to use netdev_dbg
Date: Thu, 18 Aug 2016 23:03:34 -0700
Message-ID: <1471586616-64728-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1471586616-64728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:23047 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754626AbcHSGDy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 02:03:54 -0400
In-Reply-To: <1471586616-64728-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Instead of the home brewed macro make use of netdev_dbg same as
the ixgbe driver.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 11 ++++-------
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  1 +
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index be52f59..5639fbe 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -502,12 +502,9 @@ extern void ixgbevf_write_eitr(struct ixgbevf_q_vector *q_vector);
 void ixgbe_napi_add_all(struct ixgbevf_adapter *adapter);
 void ixgbe_napi_del_all(struct ixgbevf_adapter *adapter);
 
-#ifdef DEBUG
-char *ixgbevf_get_hw_dev_name(struct ixgbe_hw *hw);
-#define hw_dbg(hw, format, arg...) \
-	printk(KERN_DEBUG "%s: " format, ixgbevf_get_hw_dev_name(hw), ##arg)
-#else
-#define hw_dbg(hw, format, arg...) do {} while (0)
-#endif
+#define ixgbevf_hw_to_netdev(hw) \
+	(((struct ixgbevf_adapter *)(hw)->back)->netdev)
 
+#define hw_dbg(hw, format, arg...) \
+	netdev_dbg(ixgbevf_hw_to_netdev(hw), format, ## arg)
 #endif /* _IXGBEVF_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index d9d6616..8d4f535 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2993,6 +2993,7 @@ static void ixgbevf_free_all_tx_resources(struct ixgbevf_adapter *adapter)
  **/
 int ixgbevf_setup_tx_resources(struct ixgbevf_ring *tx_ring)
 {
+	struct ixgbevf_adapter *adapter = netdev_priv(tx_ring->netdev);
 	int size;
 
 	size = sizeof(struct ixgbevf_tx_buffer) * tx_ring->count;
-- 
2.7.4
