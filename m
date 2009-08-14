From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 04/12] ixgbe: Add support for NETIF_F_FCOE_MTU to
	82599 devices
Date: Fri, 14 Aug 2009 15:42:17 -0700
Message-ID: <20090814224217.1640.49274.stgit@localhost.localdomain>
References: <20090814223857.1640.26881.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	gospo@redhat.com, Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.emeryville.ca.mail.comcast.net ([76.96.27.211]:55865
	"EHLO QMTA11.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756881AbZHNWmj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 18:42:39 -0400
In-Reply-To: <20090814223857.1640.26881.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Enable netdev feature flag bit NETIF_F_FCOE_MTU for 82599 devices and enable
jumbo frame correspondingly when NETIF_F_FCOE_MTU is set.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_dcb_nl.c |    4 ++++
 drivers/net/ixgbe/ixgbe_main.c   |    6 +++---
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ixgbe/ixgbe_dcb_nl.c
index 116f12c..34bca45 100644
--- a/drivers/net/ixgbe/ixgbe_dcb_nl.c
+++ b/drivers/net/ixgbe/ixgbe_dcb_nl.c
@@ -148,8 +148,10 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 				IXGBE_FCRETA_SIZE;
 			netdev->features |= NETIF_F_FCOE_CRC;
 			netdev->features |= NETIF_F_FSO;
+			netdev->features |= NETIF_F_FCOE_MTU;
 			netdev->vlan_features |= NETIF_F_FCOE_CRC;
 			netdev->vlan_features |= NETIF_F_FSO;
+			netdev->vlan_features |= NETIF_F_FCOE_MTU;
 			netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
 			netdev_features_change(netdev);
 		}
@@ -180,8 +182,10 @@ static u8 ixgbe_dcbnl_set_state(struct net_device *netdev, u8 state)
 				adapter->ring_feature[RING_F_FCOE].indices = 0;
 				netdev->features &= ~NETIF_F_FCOE_CRC;
 				netdev->features &= ~NETIF_F_FSO;
+				netdev->features &= ~NETIF_F_FCOE_MTU;
 				netdev->vlan_features &= ~NETIF_F_FCOE_CRC;
 				netdev->vlan_features &= ~NETIF_F_FSO;
+				netdev->vlan_features &= ~NETIF_F_FCOE_MTU;
 				netdev->fcoe_ddp_xid = 0;
 				netdev_features_change(netdev);
 			}
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 8a8518d..d69d277 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2026,7 +2026,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	else
 		hlreg0 |= IXGBE_HLREG0_JUMBOEN;
 #ifdef IXGBE_FCOE
-	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
+	if (netdev->features & NETIF_F_FCOE_MTU)
 		hlreg0 |= IXGBE_HLREG0_JUMBOEN;
 #endif
 	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
@@ -2057,7 +2057,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			rx_ring->flags |= IXGBE_RING_RX_PS_ENABLED;
 
 #ifdef IXGBE_FCOE
-		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+		if (netdev->features & NETIF_F_FCOE_MTU) {
 			struct ixgbe_ring_feature *f;
 			f = &adapter->ring_feature[RING_F_FCOE];
 			if ((i >= f->mask) && (i < f->mask + f->indices)) {
@@ -2609,7 +2609,7 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 
 #ifdef IXGBE_FCOE
 	/* adjust max frame to be able to do baby jumbo for FCoE */
-	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
+	if ((netdev->features & NETIF_F_FCOE_MTU) &&
 	    (max_frame < IXGBE_FCOE_JUMBO_FRAME_SIZE))
 		max_frame = IXGBE_FCOE_JUMBO_FRAME_SIZE;
 

