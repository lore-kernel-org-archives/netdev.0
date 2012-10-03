From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 4/5] ixgbe: fix poll loop for FDIRCTRL.INIT_DONE bit
Date: Wed,  3 Oct 2012 15:27:10 -0700
Message-ID: <1349303231-28855-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, shashi-sm@users.sf.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43800 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756707Ab2JCW1S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 18:27:18 -0400
In-Reply-To: <1349303231-28855-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

The loop in ixgbe_reinit_fdir_tables_82599() only polls for up to 100us
resulting in failures to update the FDIR filter table at 1Gbps and 10Gbps
when under load.

The poll times for FDIRCTRL.INIT_DONE are 55us, 550us and 5.5ms for 10Gbps,
1Gbps and 100Mbps respectively.

This patch sets the wait time to be the same as in ixgbe_fdir_enable_82599()

Reported-by: Bhushan <shashi-sm@users.sf.net>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
index 18bf08c..1077cb2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c
@@ -1099,7 +1099,7 @@ s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw)
 		if (IXGBE_READ_REG(hw, IXGBE_FDIRCTRL) &
 		                   IXGBE_FDIRCTRL_INIT_DONE)
 			break;
-		udelay(10);
+		usleep_range(1000, 2000);
 	}
 	if (i >= IXGBE_FDIR_INIT_DONE_POLL) {
 		hw_dbg(hw, "Flow Director Signature poll time exceeded!\n");
-- 
1.7.11.4
