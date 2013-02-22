From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] bnx2x: remove dead code and make local funcs static
Date: Fri, 22 Feb 2013 10:01:10 -0800
Message-ID: <20130222100110.057520e1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eilon Greenstein <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36411 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758820Ab3BVSBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2013 13:01:33 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so596082pad.9
        for <netdev@vger.kernel.org>; Fri, 22 Feb 2013 10:01:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sparse warned about several functions that were unnecessarily global.
After making them static, discovered that several functions were actually never used.

Compile tested only.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c	2013-01-24 08:39:16.000000000 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c	2013-02-21 21:30:43.266173259 -0800
@@ -98,7 +98,7 @@ static inline int bnx2x_pfvf_status_code
 	}
 }
 
-int bnx2x_send_msg2pf(struct bnx2x *bp, u8 *done, dma_addr_t msg_mapping)
+static int bnx2x_send_msg2pf(struct bnx2x *bp, u8 *done, dma_addr_t msg_mapping)
 {
 	struct cstorm_vf_zone_data __iomem *zone_data =
 		REG_ADDR(bp, PXP_VF_ADDR_CSDM_GLOBAL_START);
@@ -141,7 +141,7 @@ int bnx2x_send_msg2pf(struct bnx2x *bp,
 	return 0;
 }
 
-int bnx2x_get_vf_id(struct bnx2x *bp, u32 *vf_id)
+static int bnx2x_get_vf_id(struct bnx2x *bp, u32 *vf_id)
 {
 	u32 me_reg;
 	int tout = 10, interval = 100; /* Wait for 1 sec */
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c	2013-02-05 09:22:48.000000000 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c	2013-02-21 21:36:46.057481259 -0800
@@ -13013,64 +13013,6 @@ static int bnx2x_84833_common_init_phy(s
 	return 0;
 }
 
-static int bnx2x_84833_pre_init_phy(struct bnx2x *bp,
-				    struct bnx2x_phy *phy,
-				    u8 port)
-{
-	u16 val, cnt;
-	/* Wait for FW completing its initialization. */
-	for (cnt = 0; cnt < 1500; cnt++) {
-		bnx2x_cl45_read(bp, phy,
-				MDIO_PMA_DEVAD,
-				MDIO_PMA_REG_CTRL, &val);
-		if (!(val & (1<<15)))
-			break;
-		usleep_range(1000, 2000);
-	}
-	if (cnt >= 1500) {
-		DP(NETIF_MSG_LINK, "84833 reset timeout\n");
-		return -EINVAL;
-	}
-
-	/* Put the port in super isolate mode. */
-	bnx2x_cl45_read(bp, phy,
-			MDIO_CTL_DEVAD,
-			MDIO_84833_TOP_CFG_XGPHY_STRAP1, &val);
-	val |= MDIO_84833_SUPER_ISOLATE;
-	bnx2x_cl45_write(bp, phy,
-			 MDIO_CTL_DEVAD,
-			 MDIO_84833_TOP_CFG_XGPHY_STRAP1, val);
-
-	/* Save spirom version */
-	bnx2x_save_848xx_spirom_version(phy, bp, port);
-	return 0;
-}
-
-int bnx2x_pre_init_phy(struct bnx2x *bp,
-				  u32 shmem_base,
-				  u32 shmem2_base,
-				  u32 chip_id,
-				  u8 port)
-{
-	int rc = 0;
-	struct bnx2x_phy phy;
-	if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base, shmem2_base,
-			       port, &phy) != 0) {
-		DP(NETIF_MSG_LINK, "populate_phy failed\n");
-		return -EINVAL;
-	}
-	bnx2x_set_mdio_clk(bp, chip_id, phy.mdio_ctrl);
-	switch (phy.type) {
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833:
-	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84834:
-		rc = bnx2x_84833_pre_init_phy(bp, &phy, port);
-		break;
-	default:
-		break;
-	}
-	return rc;
-}
-
 static int bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 				     u32 shmem2_base_path[], u8 phy_index,
 				     u32 ext_phy_type, u32 chip_id)
