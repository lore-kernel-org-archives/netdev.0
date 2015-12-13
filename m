From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/17] e1000: get rid of duplicate exit path
Date: Sun, 13 Dec 2015 00:31:24 -0800
Message-ID: <1449995490-17020-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jean Sacren <sakiwit@gmail.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4841 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751182AbbLMIbh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Dec 2015 03:31:37 -0500
In-Reply-To: <1449995490-17020-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jean Sacren <sakiwit@gmail.com>

By using goto statement, we can achieve sharing the same exit path so
that code duplication could be minimized.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_hw.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_hw.c b/drivers/net/ethernet/intel/e1000/e1000_hw.c
index dbae55e..9c06456 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_hw.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_hw.c
@@ -2822,14 +2822,13 @@ s32 e1000_read_phy_reg(struct e1000_hw *hw, u32 reg_addr, u16 *phy_data)
 	    (reg_addr > MAX_PHY_MULTI_PAGE_REG)) {
 		ret_val = e1000_write_phy_reg_ex(hw, IGP01E1000_PHY_PAGE_SELECT,
 						 (u16) reg_addr);
-		if (ret_val) {
-			spin_unlock_irqrestore(&e1000_phy_lock, flags);
-			return ret_val;
-		}
+		if (ret_val)
+			goto out;
 	}
 
 	ret_val = e1000_read_phy_reg_ex(hw, MAX_PHY_REG_ADDRESS & reg_addr,
 					phy_data);
+out:
 	spin_unlock_irqrestore(&e1000_phy_lock, flags);
 
 	return ret_val;
-- 
2.5.0
