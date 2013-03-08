From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] e1000e: cleanup - move defines to appropriate header file
Date: Fri,  8 Mar 2013 02:07:17 -0800
Message-ID: <1362737237-13363-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51324 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934017Ab3CHKHg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Mar 2013 05:07:36 -0500
In-Reply-To: <1362737237-13363-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/82571.h   | 2 ++
 drivers/net/ethernet/intel/e1000e/defines.h | 3 +++
 drivers/net/ethernet/intel/e1000e/ethtool.c | 6 ++----
 drivers/net/ethernet/intel/e1000e/netdev.c  | 5 -----
 4 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/82571.h b/drivers/net/ethernet/intel/e1000e/82571.h
index 85cb1a3..08e24dc 100644
--- a/drivers/net/ethernet/intel/e1000e/82571.h
+++ b/drivers/net/ethernet/intel/e1000e/82571.h
@@ -44,6 +44,8 @@
 #define E1000_EIAC_82574	0x000DC	/* Ext. Interrupt Auto Clear - RW */
 #define E1000_EIAC_MASK_82574	0x01F00000
 
+#define E1000_IVAR_INT_ALLOC_VALID	0x8
+
 /* Manageability Operation Mode mask */
 #define E1000_NVM_INIT_CTRL2_MNGM	0x6000
 
diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index e6fe090..b7c664f 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -216,6 +216,8 @@
 #define E1000_CTRL_MEHE     0x00080000  /* Memory Error Handling Enable */
 #define E1000_CTRL_SWDPIN0  0x00040000  /* SWDPIN 0 value */
 #define E1000_CTRL_SWDPIN1  0x00080000  /* SWDPIN 1 value */
+#define E1000_CTRL_ADVD3WUC 0x00100000  /* D3 WUC */
+#define E1000_CTRL_EN_PHY_PWR_MGMT 0x00200000 /* PHY PM enable */
 #define E1000_CTRL_SWDPIO0  0x00400000  /* SWDPIN 0 Input or output */
 #define E1000_CTRL_RST      0x04000000  /* Global reset */
 #define E1000_CTRL_RFCE     0x08000000  /* Receive Flow Control enable */
@@ -310,6 +312,7 @@
 
 /* SerDes Control */
 #define E1000_SCTL_DISABLE_SERDES_LOOPBACK 0x0400
+#define E1000_SCTL_ENABLE_SERDES_LOOPBACK	0x0410
 
 /* Receive Checksum Control */
 #define E1000_RXCSUM_TUOFL     0x00000200   /* TCP / UDP checksum offload */
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 23d5d90..8f5832c 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1432,8 +1432,7 @@ static int e1000_set_82571_fiber_loopback(struct e1000_adapter *adapter)
 	/* special write to serdes control register to enable SerDes analog
 	 * loopback
 	 */
-#define E1000_SERDES_LB_ON 0x410
-	ew32(SCTL, E1000_SERDES_LB_ON);
+	ew32(SCTL, E1000_SCTL_ENABLE_SERDES_LOOPBACK);
 	e1e_flush();
 	usleep_range(10000, 20000);
 
@@ -1527,8 +1526,7 @@ static void e1000_loopback_cleanup(struct e1000_adapter *adapter)
 	case e1000_82572:
 		if (hw->phy.media_type == e1000_media_type_fiber ||
 		    hw->phy.media_type == e1000_media_type_internal_serdes) {
-#define E1000_SERDES_LB_OFF 0x400
-			ew32(SCTL, E1000_SERDES_LB_OFF);
+			ew32(SCTL, E1000_SCTL_DISABLE_SERDES_LOOPBACK);
 			e1e_flush();
 			usleep_range(10000, 20000);
 			break;
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index b085ce1..b4eab18 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1957,7 +1957,6 @@ static void e1000_configure_msix(struct e1000_adapter *adapter)
 		ew32(RFCTL, rfctl);
 	}
 
-#define E1000_IVAR_INT_ALLOC_VALID	0x8
 	/* Configure Rx vector */
 	rx_ring->ims_val = E1000_IMS_RXQ0;
 	adapter->eiac_mask |= rx_ring->ims_val;
@@ -5911,10 +5910,6 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake,
 		}
 
 		ctrl = er32(CTRL);
-		/* advertise wake from D3Cold */
-		#define E1000_CTRL_ADVD3WUC 0x00100000
-		/* phy power management enable */
-		#define E1000_CTRL_EN_PHY_PWR_MGMT 0x00200000
 		ctrl |= E1000_CTRL_ADVD3WUC;
 		if (!(adapter->flags2 & FLAG2_HAS_PHY_WAKEUP))
 			ctrl |= E1000_CTRL_EN_PHY_PWR_MGMT;
-- 
1.7.11.7
