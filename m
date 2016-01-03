From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH] ixgbe: constify ixgbe_mbx_operations structure
Date: Sun,  3 Jan 2016 07:55:29 +0100
Message-ID: <1451804129-32213-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2-relais-roc.national.inria.fr ([192.134.164.83]:21940 "EHLO
	mail2-relais-roc.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750855AbcACHIP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2016 02:08:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ixgbe_mbx_operations structure is never modified, so declare it as
const.  The other structure of this type is already const.

Done with the help of Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c  |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h  |    2 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
index 9993a47..4a769db 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.c
@@ -446,7 +446,7 @@ void ixgbe_init_mbx_params_pf(struct ixgbe_hw *hw)
 }
 #endif /* CONFIG_PCI_IOV */
 
-struct ixgbe_mbx_operations mbx_ops_generic = {
+const struct ixgbe_mbx_operations mbx_ops_generic = {
 	.read                   = ixgbe_read_mbx_pf,
 	.write                  = ixgbe_write_mbx_pf,
 	.read_posted            = ixgbe_read_posted_mbx,
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index 8daa95f..9119cb8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -123,6 +123,6 @@ s32 ixgbe_check_for_rst(struct ixgbe_hw *, u16);
 void ixgbe_init_mbx_params_pf(struct ixgbe_hw *);
 #endif /* CONFIG_PCI_IOV */
 
-extern struct ixgbe_mbx_operations mbx_ops_generic;
+extern const struct ixgbe_mbx_operations mbx_ops_generic;
 
 #endif /* _IXGBE_MBX_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index 5f53cc6..0edc2c2 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3477,7 +3477,7 @@ struct ixgbe_info {
 	struct ixgbe_mac_operations	*mac_ops;
 	struct ixgbe_eeprom_operations	*eeprom_ops;
 	struct ixgbe_phy_operations	*phy_ops;
-	struct ixgbe_mbx_operations	*mbx_ops;
+	const struct ixgbe_mbx_operations *mbx_ops;
 	const u32			*mvals;
 };
 
