From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] ixgbe: only compile ixgbe_debugfs.o when enabled
Date: Wed, 16 Jan 2013 01:03:48 -0800
Message-ID: <1358327029-13340-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358327029-13340-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:57242 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932355Ab3APJDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jan 2013 04:03:54 -0500
In-Reply-To: <1358327029-13340-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

This patch modifies ixgbe_debugfs.c and the Makefile for the ixgbe
driver to only compile the file when the config is enabled. This means
we can remove the #ifdef inside the ixgbe_debugfs.c file.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/Makefile        | 3 ++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c | 5 -----
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/Makefile b/drivers/net/ethernet/intel/ixgbe/Makefile
index f3a632b..687c83d 100644
--- a/drivers/net/ethernet/intel/ixgbe/Makefile
+++ b/drivers/net/ethernet/intel/ixgbe/Makefile
@@ -32,7 +32,7 @@
 
 obj-$(CONFIG_IXGBE) += ixgbe.o
 
-ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o ixgbe_debugfs.o\
+ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
               ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
               ixgbe_mbx.o ixgbe_x540.o ixgbe_lib.o ixgbe_ptp.o
 
@@ -40,4 +40,5 @@ ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
                               ixgbe_dcb_82599.o ixgbe_dcb_nl.o
 
 ixgbe-$(CONFIG_IXGBE_HWMON) += ixgbe_sysfs.o
+ixgbe-$(CONFIG_DEBUG_FS) += ixgbe_debugfs.o
 ixgbe-$(CONFIG_FCOE:m=y) += ixgbe_fcoe.o
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
index 50aa546..3504686 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_debugfs.c
@@ -24,9 +24,6 @@
   Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
 
 *******************************************************************************/
-
-#ifdef CONFIG_DEBUG_FS
-
 #include <linux/debugfs.h>
 #include <linux/module.h>
 
@@ -277,5 +274,3 @@ void ixgbe_dbg_exit(void)
 {
 	debugfs_remove_recursive(ixgbe_dbg_root);
 }
-
-#endif /* CONFIG_DEBUG_FS */
-- 
1.7.11.7
