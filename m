From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next  1/9] ixgbevf: do not print registers to dmesg in ixgbevf_get_regs
Date: Tue,  1 Oct 2013 04:33:48 -0700
Message-ID: <1380627236-3190-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:49978 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119Ab3JALd7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Oct 2013 07:33:59 -0400
In-Reply-To: <1380627236-3190-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch removes the use of hw_dbg in ixgbevf when the ixgbe_get_regs function
is called from ethtool. This goes along side a patch to ethtool which enables
proper support for ixgbevf pretty-printing of registers.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c | 55 +---------------------------
 1 file changed, 2 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index c9d0c12..84329b0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -140,58 +140,10 @@ static void ixgbevf_set_msglevel(struct net_device *netdev, u32 data)
 
 #define IXGBE_GET_STAT(_A_, _R_) (_A_->stats._R_)
 
-static char *ixgbevf_reg_names[] = {
-	"IXGBE_VFCTRL",
-	"IXGBE_VFSTATUS",
-	"IXGBE_VFLINKS",
-	"IXGBE_VFRXMEMWRAP",
-	"IXGBE_VFFRTIMER",
-	"IXGBE_VTEICR",
-	"IXGBE_VTEICS",
-	"IXGBE_VTEIMS",
-	"IXGBE_VTEIMC",
-	"IXGBE_VTEIAC",
-	"IXGBE_VTEIAM",
-	"IXGBE_VTEITR",
-	"IXGBE_VTIVAR",
-	"IXGBE_VTIVAR_MISC",
-	"IXGBE_VFRDBAL0",
-	"IXGBE_VFRDBAL1",
-	"IXGBE_VFRDBAH0",
-	"IXGBE_VFRDBAH1",
-	"IXGBE_VFRDLEN0",
-	"IXGBE_VFRDLEN1",
-	"IXGBE_VFRDH0",
-	"IXGBE_VFRDH1",
-	"IXGBE_VFRDT0",
-	"IXGBE_VFRDT1",
-	"IXGBE_VFRXDCTL0",
-	"IXGBE_VFRXDCTL1",
-	"IXGBE_VFSRRCTL0",
-	"IXGBE_VFSRRCTL1",
-	"IXGBE_VFPSRTYPE",
-	"IXGBE_VFTDBAL0",
-	"IXGBE_VFTDBAL1",
-	"IXGBE_VFTDBAH0",
-	"IXGBE_VFTDBAH1",
-	"IXGBE_VFTDLEN0",
-	"IXGBE_VFTDLEN1",
-	"IXGBE_VFTDH0",
-	"IXGBE_VFTDH1",
-	"IXGBE_VFTDT0",
-	"IXGBE_VFTDT1",
-	"IXGBE_VFTXDCTL0",
-	"IXGBE_VFTXDCTL1",
-	"IXGBE_VFTDWBAL0",
-	"IXGBE_VFTDWBAL1",
-	"IXGBE_VFTDWBAH0",
-	"IXGBE_VFTDWBAH1"
-};
-
-
 static int ixgbevf_get_regs_len(struct net_device *netdev)
 {
-	return (ARRAY_SIZE(ixgbevf_reg_names)) * sizeof(u32);
+#define IXGBE_REGS_LEN 45
+	return IXGBE_REGS_LEN * sizeof(u32);
 }
 
 static void ixgbevf_get_regs(struct net_device *netdev,
@@ -264,9 +216,6 @@ static void ixgbevf_get_regs(struct net_device *netdev,
 		regs_buff[41 + i] = IXGBE_READ_REG(hw, IXGBE_VFTDWBAL(i));
 	for (i = 0; i < 2; i++)
 		regs_buff[43 + i] = IXGBE_READ_REG(hw, IXGBE_VFTDWBAH(i));
-
-	for (i = 0; i < ARRAY_SIZE(ixgbevf_reg_names); i++)
-		hw_dbg(hw, "%s\t%8.8x\n", ixgbevf_reg_names[i], regs_buff[i]);
 }
 
 static void ixgbevf_get_drvinfo(struct net_device *netdev,
-- 
1.8.3.1
