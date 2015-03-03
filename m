From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next] i40e: Fix dependencies in the i40e driver on configfs
Date: Tue,  3 Mar 2015 12:38:55 -0800
Message-ID: <1425415135-10257-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31840 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756607AbbCCUi6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Mar 2015 15:38:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Module dependencies are broken in the case where CONFIG_I40E=y and
CONFIG_CONFIGFS_FS=m.  This fixes the broken dependency.

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/Kconfig | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index f4ff465..7216a53 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -303,6 +303,15 @@ config I40E_FCOE
 
 	  If unsure, say N.
 
+config I40E_CONFIGFS_FS
+	bool "Config File System Support (configfs)"
+	default n
+	depends on I40E && CONFIGFS_FS && !(I40E=y && CONFIGFS_FS=m)
+	---help---
+	  Provides support for the configfs file system for additional
+	  driver configuration.  Say Y here if you want to use the
+	  configuration file system in the driver.
+
 config I40EVF
 	tristate "Intel(R) XL710 X710 Virtual Function Ethernet support"
 	depends on PCI_MSI
-- 
1.9.3
