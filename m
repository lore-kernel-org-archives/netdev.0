From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/5] igbvf: Convert printks to pr_<level>
Date: Wed, 12 Oct 2011 09:18:08 -0700
Message-ID: <97c073ead234fd4565f89d56336a216f984ce82a.1318436085.git.joe@perches.com>
References: <cover.1318436085.git.joe@perches.com>
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:52321 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753566Ab1JLQSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Oct 2011 12:18:47 -0400
In-Reply-To: <cover.1318436085.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use current logging styles.

Prefix all output via #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
Neaten link status dev_info.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index b3d760b..952ffcd 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -25,6 +25,8 @@
 
 *******************************************************************************/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/init.h>
@@ -51,7 +53,7 @@ const char igbvf_driver_version[] = DRV_VERSION;
 static const char igbvf_driver_string[] =
 				"Intel(R) Virtual Function Network Driver";
 static const char igbvf_copyright[] =
-				"Copyright (c) 2009 - 2010 Intel Corporation.";
+				"Copyright (c) 2009 - 2010 Intel Corporation";
 
 static int igbvf_poll(struct napi_struct *napi, int budget);
 static void igbvf_reset(struct igbvf_adapter *);
@@ -1746,10 +1748,9 @@ void igbvf_update_stats(struct igbvf_adapter *adapter)
 
 static void igbvf_print_link_info(struct igbvf_adapter *adapter)
 {
-	dev_info(&adapter->pdev->dev, "Link is Up %d Mbps %s\n",
+	dev_info(&adapter->pdev->dev, "Link is Up %d Mbps %s Duplex\n",
 	         adapter->link_speed,
-	         ((adapter->link_duplex == FULL_DUPLEX) ?
-	          "Full Duplex" : "Half Duplex"));
+	         adapter->link_duplex == FULL_DUPLEX ? "Full" : "Half");
 }
 
 static bool igbvf_has_link(struct igbvf_adapter *adapter)
@@ -2825,9 +2826,8 @@ static struct pci_driver igbvf_driver = {
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
1.7.6.405.gc1be0
