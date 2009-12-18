From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [RFC PATCH v2 11/12] ixgbe: Add SR-IOV feature enablement code
Date: Fri, 18 Dec 2009 14:53:59 -0800
Message-ID: <20091218225358.10698.75075.stgit@localhost.localdomain>
References: <20091218225043.10698.58897.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: gospo@redhat.com, Greg Rose <gregory.v.rose@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:59180 "EHLO
	QMTA09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933269AbZLRWyP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2009 17:54:15 -0500
In-Reply-To: <20091218225043.10698.58897.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Adds code to the core 82599 module to support SR-IOV features of the 82599
network controller

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_82599.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 5383405..8d555a9 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -31,6 +31,7 @@
 
 #include "ixgbe.h"
 #include "ixgbe_phy.h"
+#include "ixgbe_mbx.h"
 
 #define IXGBE_82599_MAX_TX_QUEUES 128
 #define IXGBE_82599_MAX_RX_QUEUES 128
@@ -951,8 +952,6 @@ static s32 ixgbe_reset_hw_82599(struct ixgbe_hw *hw)
 
 	msleep(50);
 
-
-
 	/*
 	 * Store the original AUTOC/AUTOC2 values if they have not been
 	 * stored off yet.  Otherwise restore the stored original
@@ -1098,6 +1097,7 @@ static s32 ixgbe_set_vfta_82599(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 	u32 bitindex;
 	u32 bits;
 	u32 first_empty_slot;
+	u32 vt_ctl;
 
 	if (vlan > 4095)
 		return IXGBE_ERR_PARAM;
@@ -1124,14 +1124,15 @@ static s32 ixgbe_set_vfta_82599(struct ixgbe_hw *hw, u32 vlan, u32 vind,
 
 
 	/* Part 2
-	 * If the vind is set
+	 * If VT mode is set
 	 *   Either vlan_on
 	 *     make sure the vlan is in VLVF
 	 *     set the vind bit in the matching VLVFB
 	 *   Or !vlan_on
 	 *     clear the pool bit and possibly the vind
 	 */
-	if (vind) {
+	vt_ctl = IXGBE_READ_REG(hw, IXGBE_VT_CTL);
+	if (vt_ctl & IXGBE_VT_CTL_VT_ENABLE) {
 		/* find the vlanid or the first empty slot */
 		first_empty_slot = 0;
 
@@ -2655,4 +2656,5 @@ struct ixgbe_info ixgbe_82599_info = {
 	.mac_ops                = &mac_ops_82599,
 	.eeprom_ops             = &eeprom_ops_82599,
 	.phy_ops                = &phy_ops_82599,
+	.mbx_ops                = &mbx_ops_82599,
 };

