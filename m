From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/5] igbvf: Update module identification strings
Date: Fri, 21 Oct 2011 03:31:57 -0700
Message-ID: <1319193121-2729-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: "Williams, Mitch A" <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:30637 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754050Ab1JUKcF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Oct 2011 06:32:05 -0400
In-Reply-To: <1319193121-2729-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Williams, Mitch A" <mitch.a.williams@intel.com>

Update adapter identification strings to properly indicate i350 VF devices
in the VF driver. Change the driver ID string to remove 82576-specific
wording. Update copyright date.

Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Sibai Li <sibai.li@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igbvf/netdev.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index db29817..10e3c9c 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -49,9 +49,9 @@
 char igbvf_driver_name[] = "igbvf";
 const char igbvf_driver_version[] = DRV_VERSION;
 static const char igbvf_driver_string[] =
-				"Intel(R) Virtual Function Network Driver";
+		  "Intel(R) Gigabit Virtual Function Network Driver";
 static const char igbvf_copyright[] =
-				"Copyright (c) 2009 - 2010 Intel Corporation.";
+		  "Copyright (c) 2009 - 2011 Intel Corporation.";
 
 static int igbvf_poll(struct napi_struct *napi, int budget);
 static void igbvf_reset(struct igbvf_adapter *);
@@ -2525,9 +2525,11 @@ static void igbvf_print_device_info(struct igbvf_adapter *adapter)
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 
-	dev_info(&pdev->dev, "Intel(R) 82576 Virtual Function\n");
+	if (hw->mac.type == e1000_vfadapt_i350)
+		dev_info(&pdev->dev, "Intel(R) I350 Virtual Function\n");
+	else
+		dev_info(&pdev->dev, "Intel(R) 82576 Virtual Function\n");
 	dev_info(&pdev->dev, "Address: %pM\n", netdev->dev_addr);
-	dev_info(&pdev->dev, "MAC: %d\n", hw->mac.type);
 }
 
 static int igbvf_set_features(struct net_device *netdev, u32 features)
@@ -2864,7 +2866,7 @@ module_exit(igbvf_exit_module);
 
 
 MODULE_AUTHOR("Intel Corporation, <e1000-devel@lists.sourceforge.net>");
-MODULE_DESCRIPTION("Intel(R) 82576 Virtual Function Network Driver");
+MODULE_DESCRIPTION("Intel(R) Gigabit Virtual Function Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-- 
1.7.6.4
