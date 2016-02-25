From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 03/15] e1000e: Set HW FIFO minimum pointer gap for non-gig speeds
Date: Wed, 24 Feb 2016 18:14:50 -0800
Message-ID: <1456366502-132841-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Raanan Avargil <raanan.avargil@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:44722 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759377AbcBYC0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 21:26:03 -0500
In-Reply-To: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raanan Avargil <raanan.avargil@intel.com>

Based on feedback from HW team, the configured value of the internal PHY
HW FIFO pointer gap was incorrect for non-gig speeds.
This patch provides the correct configuration.

Signed-off-by: Raanan Avargil <raanan.avargil@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 786d214..e7ccf5f 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1479,6 +1479,18 @@ static s32 e1000_check_for_copper_link_ich8lan(struct e1000_hw *hw)
 				hw->phy.ops.release(hw);
 				if (ret_val)
 					return ret_val;
+			} else {
+				ret_val = hw->phy.ops.acquire(hw);
+				if (ret_val)
+					return ret_val;
+
+				ret_val = e1e_wphy_locked(hw,
+							  PHY_REG(776, 20),
+							  0xC023);
+				hw->phy.ops.release(hw);
+				if (ret_val)
+					return ret_val;
+
 			}
 		}
 	}
-- 
2.5.0
