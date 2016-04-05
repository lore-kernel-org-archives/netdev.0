From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/16] fm10k: Avoid crashing the kernel
Date: Tue,  5 Apr 2016 01:01:15 -0700
Message-ID: <1459843288-40623-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:2972 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757574AbcDEIC3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2016 04:02:29 -0400
In-Reply-To: <1459843288-40623-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Use BUILD_BUG_ON() instead of BUG_ON() where appropriate to get a compile
error rather than crash the kernel.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Acked-by: Alexander Duyck <aduyck@mirantis.com>
Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 28837ae..6a9f988 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -398,7 +398,7 @@ static void fm10k_get_reg_q(struct fm10k_hw *hw, u32 *buff, int i)
 	buff[idx++] = fm10k_read_reg(hw, FM10K_TX_SGLORT(i));
 	buff[idx++] = fm10k_read_reg(hw, FM10K_PFVTCTL(i));
 
-	BUG_ON(idx != FM10K_REGS_LEN_Q);
+	BUILD_BUG_ON(idx != FM10K_REGS_LEN_Q);
 }
 
 /* If function above adds more registers this define needs to be updated */
@@ -414,7 +414,7 @@ static void fm10k_get_reg_vsi(struct fm10k_hw *hw, u32 *buff, int i)
 	for (j = 0; j < 32; j++)
 		buff[idx++] = fm10k_read_reg(hw, FM10K_RETA(i, j));
 
-	BUG_ON(idx != FM10K_REGS_LEN_VSI);
+	BUILD_BUG_ON(idx != FM10K_REGS_LEN_VSI);
 }
 
 static void fm10k_get_regs(struct net_device *netdev,
-- 
2.5.5
