From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH 3/6] ethernet/ixgbe: advertise LRO support in vlan_features
Date: Thu, 13 Aug 2015 14:02:57 -0400
Message-ID: <1439488980-44738-4-git-send-email-jarod@redhat.com>
References: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without this, the presence of a ixgbe device in a bond will not trigger
LRO support to be enabled at the bond level, even while it is enabled on
the slave itself.

This change becomes necessary when NETIF_F_LRO is added to
netdev_features.h's NETIF_F_ONE_FOR_ALL.

CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
CC: intel-wired-lan@lists.osuosl.org
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 3e6a931..0a6e4e1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -8659,8 +8659,10 @@ skip_sriov:
 
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_CAPABLE)
 		netdev->hw_features |= NETIF_F_LRO;
-	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
+	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED) {
 		netdev->features |= NETIF_F_LRO;
+		netdev->vlan_features |= NETIF_F_LRO;
+	}
 
 	/* make sure the EEPROM is good */
 	if (hw->eeprom.ops.validate_checksum(hw, NULL) < 0) {
-- 
1.8.3.1
