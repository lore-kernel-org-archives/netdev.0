From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net v2 1/6] igb: Fix ethtool loopback test for 82580 copper
Date: Fri, 27 Sep 2013 05:35:53 -0700
Message-ID: <1380285358-15685-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380285358-15685-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57204 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751203Ab3I0MgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 08:36:03 -0400
In-Reply-To: <1380285358-15685-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Add back 82580 loopback tests to ethtool.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 48cbc83..86d5142 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -1607,6 +1607,9 @@ static int igb_integrated_phy_loopback(struct igb_adapter *adapter)
 			igb_write_phy_reg(hw, I347AT4_PAGE_SELECT, 0);
 			igb_write_phy_reg(hw, PHY_CONTROL, 0x4140);
 		}
+	} else if (hw->phy.type == e1000_phy_82580) {
+		/* enable MII loopback */
+		igb_write_phy_reg(hw, I82580_PHY_LBK_CTRL, 0x8041);
 	}
 
 	/* add small delay to avoid loopback test failure */
-- 
1.8.3.1
