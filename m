From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/17] ixgbe: Add X550EM support for SFP insertion interrupt
Date: Tue, 22 Sep 2015 16:54:32 -0700
Message-ID: <1442966076-14359-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mark Rustad <mark.d.rustad@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40390 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935021AbbIVXyo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 19:54:44 -0400
In-Reply-To: <1442966076-14359-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Rustad <mark.d.rustad@intel.com>

Add support for the SFP insertion interrupt on X550EM devices with
SFPs.

Signed-off-by: Mark Rustad <mark.d.rustad@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c53bef6..369204c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -2631,6 +2631,8 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
 	case ixgbe_mac_X540:
 	case ixgbe_mac_X550:
 	case ixgbe_mac_X550EM_x:
+		if (adapter->hw.device_id == IXGBE_DEV_ID_X550EM_X_SFP)
+			mask |= IXGBE_EIMS_GPI_SDP0(&adapter->hw);
 		if (adapter->hw.phy.type == ixgbe_phy_x550em_ext_t)
 			mask |= IXGBE_EICR_GPI_SDP0_X540;
 		mask |= IXGBE_EIMS_ECC;
-- 
2.4.3
