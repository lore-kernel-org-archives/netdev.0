From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] ixgbe: do not compile ixgbe_sysfs.c when CONFIG_IXGBE_HWMON is not set
Date: Sat,  9 Jun 2012 01:21:00 -0700
Message-ID: <1339230063-12545-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8495 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752795Ab2FIIVP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jun 2012 04:21:15 -0400
In-Reply-To: <1339230063-12545-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

ixgbe_sysfs.c is only needed when CONFIG_IXGBE_HWMON is configured in the
kernel.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Acked-by: Don Skidmore <Donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/Makefile      |    4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c |    2 --
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/Makefile b/drivers/net/ethernet/intel/ixgbe/Makefile
index 0bdf06b..5fd5d04 100644
--- a/drivers/net/ethernet/intel/ixgbe/Makefile
+++ b/drivers/net/ethernet/intel/ixgbe/Makefile
@@ -34,11 +34,11 @@ obj-$(CONFIG_IXGBE) += ixgbe.o
 
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o \
               ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
-              ixgbe_mbx.o ixgbe_x540.o ixgbe_sysfs.o ixgbe_lib.o
+              ixgbe_mbx.o ixgbe_x540.o ixgbe_lib.o
 
 ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
                               ixgbe_dcb_82599.o ixgbe_dcb_nl.o
 
 ixgbe-$(CONFIG_IXGBE_PTP) += ixgbe_ptp.o
-
+ixgbe-$(CONFIG_IXGBE_HWMON) += ixgbe_sysfs.o
 ixgbe-$(CONFIG_FCOE:m=y) += ixgbe_fcoe.o
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
index 1d80b1c..2334fce 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sysfs.c
@@ -37,7 +37,6 @@
 #include <linux/netdevice.h>
 #include <linux/hwmon.h>
 
-#ifdef CONFIG_IXGBE_HWMON
 /* hwmon callback functions */
 static ssize_t ixgbe_hwmon_show_location(struct device *dev,
 					 struct device_attribute *attr,
@@ -241,5 +240,4 @@ err:
 exit:
 	return rc;
 }
-#endif /* CONFIG_IXGBE_HWMON */
 
-- 
1.7.10.2
