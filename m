From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/5] ixgbevf: Convert printks to pr_<level>
Date: Wed, 12 Oct 2011 09:18:07 -0700
Message-ID: <130402c3963706ad2f6ae443ad91aab20ebaa8a1.1318436085.git.joe@perches.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1318436085.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the current logging styles, prefix output with "ixgbevf: "

Add #define pr_fmt
Coalesce formats.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      |    6 +++-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   26 ++++++++++----------
 2 files changed, 17 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index e29ba45..c9c084b 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -27,6 +27,8 @@
 
 /* ethtool support for ixgbevf */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/slab.h>
@@ -549,8 +551,8 @@ static const u32 register_test_patterns[] = {
 	writel((W & M), (adapter->hw.hw_addr + R));                           \
 	val = readl(adapter->hw.hw_addr + R);                                 \
 	if ((W & M) != (val & M)) {                                           \
-		printk(KERN_ERR "set/check reg %04X test failed: got 0x%08X " \
-				 "expected 0x%08X\n", R, (val & M), (W & M)); \
+		pr_err("set/check reg %04X test failed: got 0x%08X expected 0x%08X\n", \
+		       R, (val & M), (W & M));                                \
 		*data = R;                                                    \
 		writel(before, (adapter->hw.hw_addr + R));                    \
 		return 1;                                                     \
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 4930c46..51e944d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -29,6 +29,9 @@
 /******************************************************************************
  Copyright (c)2006 - 2007 Myricom, Inc. for some LRO specific code
 ******************************************************************************/
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/types.h>
 #include <linux/bitops.h>
 #include <linux/module.h>
@@ -1437,7 +1440,7 @@ static int ixgbevf_write_uc_addr_list(struct net_device *netdev)
 	int count = 0;
 
 	if ((netdev_uc_count(netdev)) > 10) {
-		printk(KERN_ERR "Too many unicast filters - No Space\n");
+		pr_err("Too many unicast filters - No Space\n");
 		return -ENOSPC;
 	}
 
@@ -2135,7 +2138,7 @@ static int ixgbevf_init_interrupt_scheme(struct ixgbevf_adapter *adapter)
 
 	err = ixgbevf_alloc_queues(adapter);
 	if (err) {
-		printk(KERN_ERR "Unable to allocate memory for queues\n");
+		pr_err("Unable to allocate memory for queues\n");
 		goto err_alloc_queues;
 	}
 
@@ -2189,7 +2192,7 @@ static int __devinit ixgbevf_sw_init(struct ixgbevf_adapter *adapter)
 	} else {
 		err = hw->mac.ops.init_hw(hw);
 		if (err) {
-			printk(KERN_ERR "init_shared_code failed: %d\n", err);
+			pr_err("init_shared_code failed: %d\n", err);
 			goto out;
 		}
 	}
@@ -2630,8 +2633,7 @@ static int ixgbevf_open(struct net_device *netdev)
 		 * the vf can't start. */
 		if (hw->adapter_stopped) {
 			err = IXGBE_ERR_MBX;
-			printk(KERN_ERR "Unable to start - perhaps the PF"
-			       " Driver isn't up yet\n");
+			pr_err("Unable to start - perhaps the PF Driver isn't up yet\n");
 			goto err_setup_reset;
 		}
 	}
@@ -2842,10 +2844,8 @@ static bool ixgbevf_tx_csum(struct ixgbevf_adapter *adapter,
 				break;
 			default:
 				if (unlikely(net_ratelimit())) {
-					printk(KERN_WARNING
-					       "partial checksum but "
-					       "proto=%x!\n",
-					       skb->protocol);
+					pr_warn("partial checksum but proto=%x!\n",
+						skb->protocol);
 				}
 				break;
 			}
@@ -3414,7 +3414,7 @@ static int __devinit ixgbevf_probe(struct pci_dev *pdev,
 	memcpy(netdev->perm_addr, adapter->hw.mac.addr, netdev->addr_len);
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
-		printk(KERN_ERR "invalid MAC address\n");
+		pr_err("invalid MAC address\n");
 		err = -EIO;
 		goto err_sw_init;
 	}
@@ -3535,10 +3535,10 @@ static struct pci_driver ixgbevf_driver = {
 static int __init ixgbevf_init_module(void)
 {
 	int ret;
-	printk(KERN_INFO "ixgbevf: %s - version %s\n", ixgbevf_driver_string,
-	       ixgbevf_driver_version);
+	pr_info("%s - version %s\n",
+		ixgbevf_driver_string, ixgbevf_driver_version);
 
-	printk(KERN_INFO "%s\n", ixgbevf_copyright);
+	pr_info("%s\n", ixgbevf_copyright);
 
 	ret = pci_register_driver(&ixgbevf_driver);
 	return ret;
-- 
1.7.6.405.gc1be0
