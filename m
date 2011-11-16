From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 4/8] igbvf: Convert printks to pr_<level>
Date: Wed, 16 Nov 2011 04:51:28 -0800
Message-ID: <1321447892-14381-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1321447892-14381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Joe Perches <joe@perches.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:24669 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755476Ab1KPMvi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 07:51:38 -0500
In-Reply-To: <1321447892-14381-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on the previous patch from Joe Perches <joe@perches.com>

Use current logging styles.

Prefix all output via #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Neaten link status dev_info.

-v2 Remove Copyright changes and fix-up patch to make it checkpatch.pl
    compliant.

CC: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index cca7812..d076a8d 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -25,6 +25,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
@@ -1746,10 +1748,9 @@ void igbvf_update_stats(struct igbvf_adapter *adapter)
 
 static void igbvf_print_link_info(struct igbvf_adapter *adapter)
 {
-	dev_info(&adapter->pdev->dev, "Link is Up %d Mbps %s\n",
-	         adapter->link_speed,
-	         ((adapter->link_duplex == FULL_DUPLEX) ?
-	          "Full Duplex" : "Half Duplex"));
+	dev_info(&adapter->pdev->dev, "Link is Up %d Mbps %s Duplex\n",
+		 adapter->link_speed,
+		 adapter->link_duplex == FULL_DUPLEX ? "Full" : "Half");
 }
 
 static bool igbvf_has_link(struct igbvf_adapter *adapter)
@@ -2842,9 +2843,8 @@ static struct pci_driver igbvf_driver = {
 static int __init igbvf_init_module(void)
 {
 	int ret;
-	printk(KERN_INFO "%s - version %s\n",
-	       igbvf_driver_string, igbvf_driver_version);
-	printk(KERN_INFO "%s\n", igbvf_copyright);
+	pr_info("%s - version %s\n", igbvf_driver_string, igbvf_driver_version);
+	pr_info("%s\n", igbvf_copyright);
 
 	ret = pci_register_driver(&igbvf_driver);
 
-- 
1.7.6.4
