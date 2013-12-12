From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/15] i40e: add netdev ops helper function
Date: Thu, 12 Dec 2013 04:40:40 -0800
Message-ID: <1386852051-27907-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Elizabeth Kappler <elizabeth.m.kappler@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:12130 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751696Ab3LLMlA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Dec 2013 07:41:00 -0500
In-Reply-To: <1386852051-27907-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elizabeth Kappler <elizabeth.m.kappler@intel.com>

Add a small helper function for assigning netdev_ops.
trivial:
  move include down
  small nearby whitespace fixes for readablility

Change-Id: Ib1c082a7bc9eedc1d3cfa5515720e4ef8f9f07cd
Signed-off-by: Elizabeth Kappler <elizabeth.m.kappler@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  2 +-
 drivers/net/ethernet/intel/i40e/i40e_main.c | 13 ++++++++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index 001d7cf..385d3ff 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -43,13 +43,13 @@
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/tcp.h>
-#include <linux/sctp.h>
 #include <linux/pkt_sched.h>
 #include <linux/ipv6.h>
 #include <net/checksum.h>
 #include <net/ip6_checksum.h>
 #include <linux/ethtool.h>
 #include <linux/if_vlan.h>
+#include <linux/sctp.h>
 #include "i40e_type.h"
 #include "i40e_prototype.h"
 #include "i40e_virtchnl.h"
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 1ef311a..591a6e3 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -5849,6 +5849,15 @@ static const struct net_device_ops i40e_netdev_ops = {
 };
 
 /**
+ * i40e_assign_netdev_ops - Initialize netdev operations function pointers
+ * @dev: ptr to the netdev struct
+ **/
+static void i40e_assign_netdev_ops(struct net_device *dev)
+{
+	dev->netdev_ops = &i40e_netdev_ops;
+}
+
+/**
  * i40e_config_netdev - Setup the netdev flags
  * @vsi: the VSI being configured
  *
@@ -5919,8 +5928,9 @@ static int i40e_config_netdev(struct i40e_vsi *vsi)
 	/* Setup netdev TC information */
 	i40e_vsi_config_netdev_tc(vsi, vsi->tc_config.enabled_tc);
 
-	netdev->netdev_ops = &i40e_netdev_ops;
+	i40e_assign_netdev_ops(netdev);
 	netdev->watchdog_timeo = 5 * HZ;
+
 	i40e_set_ethtool_ops(netdev);
 
 	return 0;
@@ -7653,6 +7663,7 @@ static int __init i40e_init_module(void)
 	pr_info("%s: %s - version %s\n", i40e_driver_name,
 		i40e_driver_string, i40e_driver_version_str);
 	pr_info("%s: %s\n", i40e_driver_name, i40e_copyright);
+
 	i40e_dbg_init();
 	return pci_register_driver(&i40e_driver);
 }
-- 
1.8.3.1
