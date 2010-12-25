From: jeffrey.t.kirsher@intel.com
Subject: [net-next-2.6 13/15] ixgbe: Add SR-IOV feature support to X540
Date: Fri, 24 Dec 2010 22:06:12 -0800
Message-ID: <1293257174-15498-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:28057 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750754Ab0LYGHN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Dec 2010 01:07:13 -0500
To: davem@davemloft.net
In-Reply-To: <1293257174-15498-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

Add X540 specific feature support to X540

Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe_main.c |    2 +-
 drivers/net/ixgbe/ixgbe_mbx.c  |    4 +++-
 drivers/net/ixgbe/ixgbe_x540.c |    2 ++
 3 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ca9036d..c905625 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6889,7 +6889,7 @@ static void __devinit ixgbe_probe_vf(struct ixgbe_adapter *adapter,
 	struct ixgbe_hw *hw = &adapter->hw;
 	int err;
 
-	if (hw->mac.type != ixgbe_mac_82599EB || !max_vfs)
+	if (hw->mac.type == ixgbe_mac_82598EB || !max_vfs)
 		return;
 
 	/* The 82599 supports up to 64 VFs per physical function
diff --git a/drivers/net/ixgbe/ixgbe_mbx.c b/drivers/net/ixgbe/ixgbe_mbx.c
index 027c628..ea82c5a 100644
--- a/drivers/net/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ixgbe/ixgbe_mbx.c
@@ -321,9 +321,11 @@ static s32 ixgbe_check_for_rst_pf(struct ixgbe_hw *hw, u16 vf_number)
 
 	switch (hw->mac.type) {
 	case ixgbe_mac_82599EB:
-	case ixgbe_mac_X540:
 		vflre = IXGBE_READ_REG(hw, IXGBE_VFLRE(reg_offset));
 		break;
+	case ixgbe_mac_X540:
+		vflre = IXGBE_READ_REG(hw, IXGBE_VFLREC(reg_offset));
+		break;
 	default:
 		break;
 	}
diff --git a/drivers/net/ixgbe/ixgbe_x540.c b/drivers/net/ixgbe/ixgbe_x540.c
index cf88515..3a89239 100644
--- a/drivers/net/ixgbe/ixgbe_x540.c
+++ b/drivers/net/ixgbe/ixgbe_x540.c
@@ -685,6 +685,8 @@ static struct ixgbe_mac_operations mac_ops_X540 = {
 	.fc_enable              = &ixgbe_fc_enable_generic,
 	.init_uta_tables        = &ixgbe_init_uta_tables_generic,
 	.setup_sfp              = NULL,
+	.set_mac_anti_spoofing  = &ixgbe_set_mac_anti_spoofing,
+	.set_vlan_anti_spoofing = &ixgbe_set_vlan_anti_spoofing,
 };
 
 static struct ixgbe_eeprom_operations eeprom_ops_X540 = {
-- 
1.7.3.4

