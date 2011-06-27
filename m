From: Jon Mason <jdmason@kudzu.us>
Subject: [PATCH 1/5] ixgb: use PCI_VENDOR_ID_*
Date: Mon, 27 Jun 2011 13:03:23 -0500
Message-ID: <1309197803-16724-1-git-send-email-jdmason@kudzu.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Use PCI_VENDOR_ID_* from pci_ids.h instead of creating #define locally.

Signed-off-by: Jon Mason <jdmason@kudzu.us>
---
 drivers/net/ixgb/ixgb_hw.c   |    5 +++--
 drivers/net/ixgb/ixgb_ids.h  |    5 -----
 drivers/net/ixgb/ixgb_main.c |   10 +++++-----
 3 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_hw.c b/drivers/net/ixgb/ixgb_hw.c
index 6cb2e42..f32e25b 100644
--- a/drivers/net/ixgb/ixgb_hw.c
+++ b/drivers/net/ixgb/ixgb_hw.c
@@ -32,6 +32,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <linux/pci_ids.h>
 #include "ixgb_hw.h"
 #include "ixgb_ids.h"
 
@@ -96,7 +97,7 @@ static u32 ixgb_mac_reset(struct ixgb_hw *hw)
 	ASSERT(!(ctrl_reg & IXGB_CTRL0_RST));
 #endif
 
-	if (hw->subsystem_vendor_id == SUN_SUBVENDOR_ID) {
+	if (hw->subsystem_vendor_id == PCI_VENDOR_ID_SUN) {
 		ctrl_reg =  /* Enable interrupt from XFP and SerDes */
 			   IXGB_CTRL1_GPI0_EN |
 			   IXGB_CTRL1_SDP6_DIR |
@@ -270,7 +271,7 @@ ixgb_identify_phy(struct ixgb_hw *hw)
 	}
 
 	/* update phy type for sun specific board */
-	if (hw->subsystem_vendor_id == SUN_SUBVENDOR_ID)
+	if (hw->subsystem_vendor_id == PCI_VENDOR_ID_SUN)
 		phy_type = ixgb_phy_type_bcm;
 
 	return phy_type;
diff --git a/drivers/net/ixgb/ixgb_ids.h b/drivers/net/ixgb/ixgb_ids.h
index 2a58847..32c1b30 100644
--- a/drivers/net/ixgb/ixgb_ids.h
+++ b/drivers/net/ixgb/ixgb_ids.h
@@ -33,11 +33,6 @@
 ** The Device and Vendor IDs for 10 Gigabit MACs
 **********************************************************************/
 
-#define INTEL_VENDOR_ID             0x8086
-#define INTEL_SUBVENDOR_ID          0x8086
-#define SUN_VENDOR_ID               0x108E
-#define SUN_SUBVENDOR_ID            0x108E
-
 #define IXGB_DEVICE_ID_82597EX      0x1048
 #define IXGB_DEVICE_ID_82597EX_SR   0x1A48
 #define IXGB_DEVICE_ID_82597EX_LR   0x1B48
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 6a130eb..7dd4f8b 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -54,13 +54,13 @@ MODULE_PARM_DESC(copybreak,
  *   Class, Class Mask, private data (not used) }
  */
 static DEFINE_PCI_DEVICE_TABLE(ixgb_pci_tbl) = {
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX,
+	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_CX4,
+	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX_CX4,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_SR,
+	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX_SR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{INTEL_VENDOR_ID, IXGB_DEVICE_ID_82597EX_LR,
+	{PCI_VENDOR_ID_INTEL, IXGB_DEVICE_ID_82597EX_LR,
 	 PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 
 	/* required last entry */
@@ -195,7 +195,7 @@ ixgb_irq_enable(struct ixgb_adapter *adapter)
 {
 	u32 val = IXGB_INT_RXT0 | IXGB_INT_RXDMT0 |
 		  IXGB_INT_TXDW | IXGB_INT_LSC;
-	if (adapter->hw.subsystem_vendor_id == SUN_SUBVENDOR_ID)
+	if (adapter->hw.subsystem_vendor_id == PCI_VENDOR_ID_SUN)
 		val |= IXGB_INT_GPI0;
 	IXGB_WRITE_REG(&adapter->hw, IMS, val);
 	IXGB_WRITE_FLUSH(&adapter->hw);
-- 
1.7.5.4


------------------------------------------------------------------------------
All of the data generated in your IT infrastructure is seriously valuable.
Why? It contains a definitive record of application performance, security 
threats, fraudulent activity, and more. Splunk takes this data and makes 
sense of it. IT sense. And common sense.
http://p.sf.net/sfu/splunk-d2d-c2
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
