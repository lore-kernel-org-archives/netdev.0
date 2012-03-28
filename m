From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/4] intel: make wired ethernet driver message level consistent (rev2)
Date: Tue, 27 Mar 2012 23:52:26 -0700
Message-ID: <1332917548-13102-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: stephen hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:1121 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751082Ab2C1Gwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2012 02:52:33 -0400
In-Reply-To: <1332917548-13102-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: stephen hemminger <shemminger@vyatta.com>

Dan Carpenter noticed that ixgbevf initial default was different than
the rest. But the problem is broader than that, only one Intel driver (ixgb)
was doing it almost right.

The convention for default debug level should be consistent among
Intel drivers and follow established convention.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000/e1000_main.c     |    5 +++--
 drivers/net/ethernet/intel/e1000e/netdev.c        |    7 ++++++-
 drivers/net/ethernet/intel/igb/igb_main.c         |    7 ++++++-
 drivers/net/ethernet/intel/igbvf/netdev.c         |    7 ++++++-
 drivers/net/ethernet/intel/ixgb/ixgb_main.c       |    6 +++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    9 ++++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    7 +++++--
 7 files changed, 35 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index bcba9cf..4348b6f 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -217,7 +217,8 @@ MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-static int debug = NETIF_MSG_DRV | NETIF_MSG_PROBE;
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
@@ -981,7 +982,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter = netdev_priv(netdev);
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
-	adapter->msg_enable = (1 << debug) - 1;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 	adapter->bars = bars;
 	adapter->need_ioport = need_ioport;
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 7152eb1..2c38a65 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -60,6 +60,11 @@
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug = -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
 static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state);
 
 static const struct e1000_info *e1000_info_tbl[] = {
@@ -6172,7 +6177,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->hw.adapter = adapter;
 	adapter->hw.mac.type = ei->mac;
 	adapter->max_hw_frame_size = ei->max_hw_frame_size;
-	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index c490241..5ec3159 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -238,6 +238,11 @@ MODULE_DESCRIPTION("Intel(R) Gigabit Ethernet Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug = -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
 struct igb_reg_info {
 	u32 ofs;
 	char *name;
@@ -1893,7 +1898,7 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	hw = &adapter->hw;
 	hw->back = adapter;
-	adapter->msg_enable = NETIF_MSG_DRV | NETIF_MSG_PROBE;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 217c143..d61ca2a 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -55,6 +55,11 @@ static const char igbvf_driver_string[] =
 static const char igbvf_copyright[] =
 		  "Copyright (c) 2009 - 2012 Intel Corporation.";
 
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug = -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
 static int igbvf_poll(struct napi_struct *napi, int budget);
 static void igbvf_reset(struct igbvf_adapter *);
 static void igbvf_set_interrupt_capability(struct igbvf_adapter *);
@@ -2649,7 +2654,7 @@ static int __devinit igbvf_probe(struct pci_dev *pdev,
 	adapter->flags = ei->flags;
 	adapter->hw.back = adapter;
 	adapter->hw.mac.type = ei->mac;
-	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
 	/* PCI config space info */
 
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 82aaa79..5fce363 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -134,8 +134,8 @@ MODULE_DESCRIPTION("Intel(R) PRO/10GbE Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-#define DEFAULT_DEBUG_LEVEL_SHIFT 3
-static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
@@ -442,7 +442,7 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
-	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
 	adapter->hw.hw_addr = pci_ioremap_bar(pdev, BAR_0);
 	if (!adapter->hw.hw_addr) {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 398fc22..6dbad2b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -141,13 +141,16 @@ module_param(allow_unsupported_sfp, uint, 0);
 MODULE_PARM_DESC(allow_unsupported_sfp,
 		 "Allow unsupported and untested SFP+ modules on 82599-based adapters");
 
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug = -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-#define DEFAULT_DEBUG_LEVEL_SHIFT 3
-
 static void ixgbe_service_event_schedule(struct ixgbe_adapter *adapter)
 {
 	if (!test_bit(__IXGBE_DOWN, &adapter->state) &&
@@ -6834,7 +6837,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	hw = &adapter->hw;
 	hw->back = adapter;
-	adapter->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
 	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
 			      pci_resource_len(pdev, 0));
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 581c659..307611a 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -91,7 +91,10 @@ MODULE_DESCRIPTION("Intel(R) 82599 Virtual Function Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-#define DEFAULT_DEBUG_LEVEL_SHIFT 3
+#define DEFAULT_MSG_ENABLE (NETIF_MSG_DRV|NETIF_MSG_PROBE|NETIF_MSG_LINK)
+static int debug = -1;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
 /* forward decls */
 static void ixgbevf_set_itr_msix(struct ixgbevf_q_vector *q_vector);
@@ -3367,7 +3370,7 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	hw = &adapter->hw;
 	hw->back = adapter;
-	adapter->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
 	/*
 	 * call save state here in standalone driver because it relies on
-- 
1.7.7.6
