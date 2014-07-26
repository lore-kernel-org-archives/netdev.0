From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 08/12] e1000e: Fix CRC errors with jumbo traffic
Date: Fri, 25 Jul 2014 21:45:18 -0700
Message-ID: <1406349922-9883-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <david.m.ertman@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:13529 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751063AbaGZEpb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2014 00:45:31 -0400
In-Reply-To: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <david.m.ertman@intel.com>

Modifying the jumbo frame workaround for 82579, i217 and i218 client parts
to increase the gap between the read and write pointers in the Tx FIFO.

Signed-off-by: Dave Ertman <david.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h | 1 +
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index d18e892..bb7ab3c 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -342,6 +342,7 @@
 #define E1000_TIPG_IPGR2_SHIFT  20
 
 #define MAX_JUMBO_FRAME_SIZE    0x3F00
+#define E1000_TX_PTR_GAP		0x1F
 
 /* Extended Configuration Control and Size */
 #define E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP      0x00000020
diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index f236861..8dbcdc8 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -2444,7 +2444,7 @@ s32 e1000_lv_jumbo_workaround_ich8lan(struct e1000_hw *hw, bool enable)
 			return ret_val;
 		e1e_rphy(hw, PHY_REG(776, 20), &data);
 		data &= ~(0x3FF << 2);
-		data |= (0x1A << 2);
+		data |= (E1000_TX_PTR_GAP << 2);
 		ret_val = e1e_wphy(hw, PHY_REG(776, 20), data);
 		if (ret_val)
 			return ret_val;
-- 
1.9.3
