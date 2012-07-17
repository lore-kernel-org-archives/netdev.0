From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] ixgbevf: Drop use of eitr_low and eitr_high for hard coded values
Date: Tue, 17 Jul 2012 03:09:15 -0700
Message-ID: <1342519759-25137-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19415 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755055Ab2GQKJZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2012 06:09:25 -0400
In-Reply-To: <1342519759-25137-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch drops the use of eitr_low and eitr_high as values being stored
in the adapter structure.  Since the values have no external way to be
changed they might as well just be hard coded values and save us the space
on the adapter structure.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |    2 --
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   12 ++++--------
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 773dafa..c62caba 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -177,8 +177,6 @@ struct ixgbevf_adapter {
 
 	/* Interrupt Throttle Rate */
 	u32 itr_setting;
-	u16 eitr_low;
-	u16 eitr_high;
 
 	/* TX */
 	struct ixgbevf_ring *tx_ring;	/* One per active queue */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 2e85d79..75af192 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -704,17 +704,17 @@ static u8 ixgbevf_update_itr(struct ixgbevf_adapter *adapter,
 
 	switch (itr_setting) {
 	case lowest_latency:
-		if (bytes_perint > adapter->eitr_low)
+		if (bytes_perint > 10)
 			retval = low_latency;
 		break;
 	case low_latency:
-		if (bytes_perint > adapter->eitr_high)
+		if (bytes_perint > 20)
 			retval = bulk_latency;
-		else if (bytes_perint <= adapter->eitr_low)
+		else if (bytes_perint <= 10)
 			retval = lowest_latency;
 		break;
 	case bulk_latency:
-		if (bytes_perint <= adapter->eitr_high)
+		if (bytes_perint <= 20)
 			retval = low_latency;
 		break;
 	}
@@ -2069,10 +2069,6 @@ static int __devinit ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 	adapter->eitr_param = 20000;
 	adapter->itr_setting = 1;
 
-	/* set defaults for eitr in MegaBytes */
-	adapter->eitr_low = 10;
-	adapter->eitr_high = 20;
-
 	/* set default ring sizes */
 	adapter->tx_ring_count = IXGBEVF_DEFAULT_TXD;
 	adapter->rx_ring_count = IXGBEVF_DEFAULT_RXD;
-- 
1.7.10.4
