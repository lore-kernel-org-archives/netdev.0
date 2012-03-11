From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] intel: make wired ethernet driver message level consistent
Date: Sat, 10 Mar 2012 16:01:53 -0800
Message-ID: <20120310160153.1d3e5f19@nehalam.linuxnetplumber.net>
References: <20120310084921.GA4647@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55557 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998Ab2CKAB6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Mar 2012 19:01:58 -0500
In-Reply-To: <20120310084921.GA4647@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter noticed that ixgbevf initial default was different than
the rest. But the problem is broader than that, only one Intel driver (ixgb)
was doing it right.

The convention for default debug level should be consistent among
Intel drivers and follow established convention.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Supersedes patch from Dan Carpenter

 drivers/net/ethernet/intel/e1000/e1000_main.c     |    5 +++--
 drivers/net/ethernet/intel/e1000e/netdev.c        |    7 ++++++-
 drivers/net/ethernet/intel/igb/igb_main.c         |    7 ++++++-
 drivers/net/ethernet/intel/igbvf/netdev.c         |    7 ++++++-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |    7 ++++++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    8 +++++++-
 6 files changed, 34 insertions(+), 7 deletions(-)

--- a/drivers/net/ethernet/intel/e1000/e1000_main.c	2012-02-27 08:43:02.348936997 -0800
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c	2012-03-10 15:50:57.199452804 -0800
@@ -215,7 +215,8 @@ MODULE_DESCRIPTION("Intel(R) PRO/1000 Ne
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-static int debug = NETIF_MSG_DRV | NETIF_MSG_PROBE;
+#define DEFAULT_DEBUG_LEVEL_SHIFT 3
+static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
@@ -979,7 +980,7 @@ static int __devinit e1000_probe(struct
 	adapter = netdev_priv(netdev);
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
-	adapter->msg_enable = (1 << debug) - 1;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 	adapter->bars = bars;
 	adapter->need_ioport = need_ioport;
 
--- a/drivers/net/ethernet/intel/e1000e/netdev.c	2012-03-04 21:12:14.059108802 -0800
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c	2012-03-10 15:51:03.759522110 -0800
@@ -60,6 +60,11 @@
 char e1000e_driver_name[] = "e1000e";
 const char e1000e_driver_version[] = DRV_VERSION;
 
+#define DEFAULT_DEBUG_LEVEL_SHIFT 3
+static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
 static void e1000e_disable_aspm(struct pci_dev *pdev, u16 state);
 
 static const struct e1000_info *e1000_info_tbl[] = {
@@ -6175,7 +6180,7 @@ static int __devinit e1000_probe(struct
 	adapter->hw.adapter = adapter;
 	adapter->hw.mac.type = ei->mac;
 	adapter->max_hw_frame_size = ei->max_hw_frame_size;
-	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 
 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
--- a/drivers/net/ethernet/intel/igb/igb_main.c	2012-02-13 09:23:53.622447001 -0800
+++ b/drivers/net/ethernet/intel/igb/igb_main.c	2012-03-10 15:51:07.295559468 -0800
@@ -238,6 +238,11 @@ MODULE_DESCRIPTION("Intel(R) Gigabit Eth
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
+#define DEFAULT_DEBUG_LEVEL_SHIFT 3
+static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
 struct igb_reg_info {
 	u32 ofs;
 	char *name;
@@ -1882,7 +1887,7 @@ static int __devinit igb_probe(struct pc
 	adapter->pdev = pdev;
 	hw = &adapter->hw;
 	hw->back = adapter;
-	adapter->msg_enable = NETIF_MSG_DRV | NETIF_MSG_PROBE;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 
 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
--- a/drivers/net/ethernet/intel/igbvf/netdev.c	2012-02-24 10:04:00.123237028 -0800
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c	2012-03-10 15:53:41.949194426 -0800
@@ -55,6 +55,11 @@ static const char igbvf_driver_string[]
 static const char igbvf_copyright[] =
 		  "Copyright (c) 2009 - 2012 Intel Corporation.";
 
+#define DEFAULT_DEBUG_LEVEL_SHIFT 3
+static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
 static int igbvf_poll(struct napi_struct *napi, int budget);
 static void igbvf_reset(struct igbvf_adapter *);
 static void igbvf_set_interrupt_capability(struct igbvf_adapter *);
@@ -2649,7 +2654,7 @@ static int __devinit igbvf_probe(struct
 	adapter->flags = ei->flags;
 	adapter->hw.back = adapter;
 	adapter->hw.mac.type = ei->mac;
-	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 
 	/* PCI config space info */
 
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-03-04 21:12:14.063108911 -0800
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c	2012-03-10 15:51:16.119652706 -0800
@@ -136,6 +136,11 @@ module_param(allow_unsupported_sfp, uint
 MODULE_PARM_DESC(allow_unsupported_sfp,
 		 "Allow unsupported and untested SFP+ modules on 82599-based adapters");
 
+#define DEFAULT_DEBUG_LEVEL_SHIFT 3
+static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) 10 Gigabit PCI Express Network Driver");
 MODULE_LICENSE("GPL");
@@ -7638,7 +7643,7 @@ static int __devinit ixgbe_probe(struct
 	adapter->pdev = pdev;
 	hw = &adapter->hw;
 	hw->back = adapter;
-	adapter->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 
 	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
 			      pci_resource_len(pdev, 0));
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c	2012-02-27 08:43:02.356936810 -0800
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c	2012-03-10 15:50:39.319263934 -0800
@@ -92,6 +92,12 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
+static int debug = DEFAULT_DEBUG_LEVEL_SHIFT;
+module_param(debug, int, 0);
+MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
+
+
+#define DEFAULT_DEBUG_LEVEL_SHIFT 3
 
 /* forward decls */
 static void ixgbevf_set_itr_msix(struct ixgbevf_q_vector *q_vector);
@@ -3367,7 +3373,7 @@ static int __devinit ixgbevf_probe(struc
 	adapter->pdev = pdev;
 	hw = &adapter->hw;
 	hw->back = adapter;
-	adapter->msg_enable = (1 << DEFAULT_DEBUG_LEVEL_SHIFT) - 1;
+	adapter->msg_enable = netif_msg_init(debug, DEFAULT_DEBUG_LEVEL_SHIFT);
 
 	/*
 	 * call save state here in standalone driver because it relies on
