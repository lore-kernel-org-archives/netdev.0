From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 09/11] ixgbevf: Adds function to set PSRTYPE register
Date: Thu, 24 Oct 2013 08:27:36 -0700
Message-ID: <1382628458-26601-10-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:61169 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755552Ab3JXP1s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Oct 2013 11:27:48 -0400
In-Reply-To: <1382628458-26601-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch creates a new function to set PSRTYPE. This function helps lay
the ground work for eventual multi queue support.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index ce27d62..c0f9aad 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -1082,6 +1082,21 @@ static void ixgbevf_configure_srrctl(struct ixgbevf_adapter *adapter, int index)
 	IXGBE_WRITE_REG(hw, IXGBE_VFSRRCTL(index), srrctl);
 }
 
+static void ixgbevf_setup_psrtype(struct ixgbevf_adapter *adapter)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+
+	/* PSRTYPE must be initialized in 82599 */
+	u32 psrtype = IXGBE_PSRTYPE_TCPHDR | IXGBE_PSRTYPE_UDPHDR |
+		      IXGBE_PSRTYPE_IPV4HDR | IXGBE_PSRTYPE_IPV6HDR |
+		      IXGBE_PSRTYPE_L2HDR;
+
+	if (adapter->num_rx_queues > 1)
+		psrtype |= 1 << 29;
+
+	IXGBE_WRITE_REG(hw, IXGBE_VFPSRTYPE, psrtype);
+}
+
 static void ixgbevf_set_rx_buffer_len(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -1129,8 +1144,7 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 	int i, j;
 	u32 rdlen;
 
-	/* PSRTYPE must be initialized in 82599 */
-	IXGBE_WRITE_REG(hw, IXGBE_VFPSRTYPE, 0);
+	ixgbevf_setup_psrtype(adapter);
 
 	/* set_rx_buffer_len must be called before ring initialization */
 	ixgbevf_set_rx_buffer_len(adapter);
-- 
1.8.3.1
