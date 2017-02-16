From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/14] ixgbe: prefix Data Center Bridge ops struct
Date: Thu, 16 Feb 2017 04:50:29 -0800
Message-ID: <20170216125041.46668-3-jeffrey.t.kirsher@intel.com>
References: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Cc: Stephen Hemminger <sthemmin@microsoft.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:7261 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754277AbdBPMup (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 16 Feb 2017 07:50:45 -0500
In-Reply-To: <20170216125041.46668-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

Since dcbnl_ops is global, it should be prefixed by ixgbe_

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h        | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c | 2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c   | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index e83444c34cf9..6530eff01a0b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -751,7 +751,7 @@ extern const struct ixgbe_info ixgbe_X550EM_x_info;
 extern const struct ixgbe_info ixgbe_x550em_a_info;
 extern const struct ixgbe_info ixgbe_x550em_a_fw_info;
 #ifdef CONFIG_IXGBE_DCB
-extern const struct dcbnl_rtnl_ops dcbnl_ops;
+extern const struct dcbnl_rtnl_ops ixgbe_dcbnl_ops;
 #endif
 
 extern char ixgbe_driver_name[];
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
index b8fc3cfec831..78c52375acc6 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
@@ -777,7 +777,7 @@ static u8 ixgbe_dcbnl_setdcbx(struct net_device *dev, u8 mode)
 	return err ? 1 : 0;
 }
 
-const struct dcbnl_rtnl_ops dcbnl_ops = {
+const struct dcbnl_rtnl_ops ixgbe_dcbnl_ops = {
 	.ieee_getets	= ixgbe_dcbnl_ieee_getets,
 	.ieee_setets	= ixgbe_dcbnl_ieee_setets,
 	.ieee_getpfc	= ixgbe_dcbnl_ieee_getpfc,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 86135c00d4b1..0b73a3607fdd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9687,7 +9687,7 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 #ifdef CONFIG_IXGBE_DCB
 	if (adapter->flags & IXGBE_FLAG_DCB_CAPABLE)
-		netdev->dcbnl_ops = &dcbnl_ops;
+		netdev->dcbnl_ops = &ixgbe_dcbnl_ops;
 #endif
 
 #ifdef IXGBE_FCOE
-- 
2.11.0
