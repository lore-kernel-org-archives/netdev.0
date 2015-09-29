From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 1/6] i40e: Move i40e_get_head into header file
Date: Mon, 28 Sep 2015 17:55:29 -0700
Message-ID: <1443488134-36387-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443488134-36387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Kiran Patil <kiran.patil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:16566 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754428AbbI2Azh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Sep 2015 20:55:37 -0400
In-Reply-To: <1443488134-36387-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kiran Patil <kiran.patil@intel.com>

i40e_get_head needs to be called in multiple files in a further patch,
prepare by moving the function into a header file.

Signed-off-by: Kiran Patil <kiran.patil@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 13 -------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h | 14 ++++++++++++++
 2 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 738aca6..9a800f9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -600,19 +600,6 @@ void i40e_free_tx_resources(struct i40e_ring *tx_ring)
 	}
 }
 
-/**
- * i40e_get_head - Retrieve head from head writeback
- * @tx_ring:  tx ring to fetch head of
- *
- * Returns value of Tx ring head based on value stored
- * in head write-back location
- **/
-static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
-{
-	void *head = (struct i40e_tx_desc *)tx_ring->desc + tx_ring->count;
-
-	return le32_to_cpu(*(volatile __le32 *)head);
-}
 
 /**
  * i40e_get_tx_pending - how many tx descriptors not processed
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index f1385a1..51487ef 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -326,4 +326,18 @@ int i40e_xmit_descriptor_count(struct sk_buff *skb, struct i40e_ring *tx_ring);
 int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 			       struct i40e_ring *tx_ring, u32 *flags);
 #endif
+
+/**
+ * i40e_get_head - Retrieve head from head writeback
+ * @tx_ring:  tx ring to fetch head of
+ *
+ * Returns value of Tx ring head based on value stored
+ * in head write-back location
+ **/
+static inline u32 i40e_get_head(struct i40e_ring *tx_ring)
+{
+	void *head = (struct i40e_tx_desc *)tx_ring->desc + tx_ring->count;
+
+	return le32_to_cpu(*(volatile __le32 *)head);
+}
 #endif /* _I40E_TXRX_H_ */
-- 
2.4.3
