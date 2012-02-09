From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 2/7] e1000e: remove unnecessary returns from void functions
Date: Thu,  9 Feb 2012 02:27:57 -0800
Message-ID: <1328783282-17760-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1328783282-17760-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:60039 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757235Ab2BIK2J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 05:28:09 -0500
In-Reply-To: <1328783282-17760-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

...and convert some goto's which simply return to just return.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/ich8lan.c |    3 ---
 drivers/net/ethernet/intel/e1000e/mac.c     |    8 ++------
 drivers/net/ethernet/intel/e1000e/netdev.c  |    7 ++-----
 3 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/ich8lan.c b/drivers/net/ethernet/intel/e1000e/ich8lan.c
index 5061d4d..942f4da 100644
--- a/drivers/net/ethernet/intel/e1000e/ich8lan.c
+++ b/drivers/net/ethernet/intel/e1000e/ich8lan.c
@@ -1762,7 +1762,6 @@ static void e1000_gate_hw_phy_config_ich8lan(struct e1000_hw *hw, bool gate)
 		extcnf_ctrl &= ~E1000_EXTCNF_CTRL_GATE_PHY_CFG;
 
 	ew32(EXTCNF_CTRL, extcnf_ctrl);
-	return;
 }
 
 /**
@@ -3768,8 +3767,6 @@ void e1000_resume_workarounds_pchlan(struct e1000_hw *hw)
 
 release:
 	hw->phy.ops.release(hw);
-
-	return;
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/e1000e/mac.c b/drivers/net/ethernet/intel/e1000e/mac.c
index 33d1b9e..be8335a 100644
--- a/drivers/net/ethernet/intel/e1000e/mac.c
+++ b/drivers/net/ethernet/intel/e1000e/mac.c
@@ -1661,7 +1661,7 @@ void e1000e_reset_adaptive(struct e1000_hw *hw)
 
 	if (!mac->adaptive_ifs) {
 		e_dbg("Not in Adaptive IFS mode!\n");
-		goto out;
+		return;
 	}
 
 	mac->current_ifs_val = 0;
@@ -1672,8 +1672,6 @@ void e1000e_reset_adaptive(struct e1000_hw *hw)
 
 	mac->in_ifs_mode = false;
 	ew32(AIT, 0);
-out:
-	return;
 }
 
 /**
@@ -1689,7 +1687,7 @@ void e1000e_update_adaptive(struct e1000_hw *hw)
 
 	if (!mac->adaptive_ifs) {
 		e_dbg("Not in Adaptive IFS mode!\n");
-		goto out;
+		return;
 	}
 
 	if ((mac->collision_delta * mac->ifs_ratio) > mac->tx_packet_delta) {
@@ -1712,6 +1710,4 @@ void e1000e_update_adaptive(struct e1000_hw *hw)
 			ew32(AIT, 0);
 		}
 	}
-out:
-	return;
 }
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 293a760..7ccd5f3 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -221,7 +221,7 @@ static void e1000e_dump(struct e1000_adapter *adapter)
 
 	/* Print Tx Ring Summary */
 	if (!netdev || !netif_running(netdev))
-		goto exit;
+		return;
 
 	dev_info(&adapter->pdev->dev, "Tx Ring Summary\n");
 	pr_info("Queue [NTU] [NTC] [bi(ntc)->dma  ] leng ntw timestamp\n");
@@ -308,7 +308,7 @@ rx_ring_summary:
 
 	/* Print Rx Ring */
 	if (!netif_msg_rx_status(adapter))
-		goto exit;
+		return;
 
 	dev_info(&adapter->pdev->dev, "Rx Ring Dump\n");
 	switch (adapter->rx_ps_pages) {
@@ -449,9 +449,6 @@ rx_ring_summary:
 			}
 		}
 	}
-
-exit:
-	return;
 }
 
 /**
-- 
1.7.7.6
