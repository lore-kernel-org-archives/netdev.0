From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 11/41]bnx2x: Removing the board type
Date: Thu, 12 Feb 2009 20:36:47 +0200
Message-ID: <1234463807.1863.143.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2500 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758264AbZBLSpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 11/41]bnx2x: Removing the board type
There are too many different board types and this field is not scalable.
Removing it and making decisions according to other fields

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    1 -
 drivers/net/bnx2x_hsi.h  |   34 +++++++---------------------------
 drivers/net/bnx2x_main.c |   20 +++++++-------------
 3 files changed, 14 insertions(+), 41 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 8c2124e..a18ace0 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -523,7 +523,6 @@ struct bnx2x_common {
 	u32			shmem_base;
 
 	u32			hw_config;
-	u32			board;
 
 	u32			bc_ver;
 
diff --git a/drivers/net/bnx2x_hsi.h b/drivers/net/bnx2x_hsi.h
index b0f41d1..85e4df6 100644
--- a/drivers/net/bnx2x_hsi.h
+++ b/drivers/net/bnx2x_hsi.h
@@ -119,35 +119,15 @@ struct shared_hw_cfg {					 /* NVRAM Offset */
 #define SHARED_HW_CFG_UMP_NC_SI_EXT_PHY_TYPE_BCM5221 0x00010000
 
 	u32 board;						/* 0x124 */
-#define SHARED_HW_CFG_BOARD_TYPE_MASK		    0x0000ffff
-#define SHARED_HW_CFG_BOARD_TYPE_SHIFT		    0
-#define SHARED_HW_CFG_BOARD_TYPE_NONE		    0x00000000
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710T1000     0x00000001
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710T1001     0x00000002
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710T1002G    0x00000003
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710T1004G    0x00000004
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710T1007G    0x00000005
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710T1015G    0x00000006
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1020G    0x00000007
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710T1003G    0x00000008
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G    0x00000009
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1021G    0x0000000a
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1023G    0x0000000b
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957710A1033G    0x0000000c
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957711T1101     0x0000000d
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957711ET1201    0x0000000e
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957711A1133G    0x0000000f
-#define SHARED_HW_CFG_BOARD_TYPE_BCM957711EA1233G   0x00000010
-
-#define SHARED_HW_CFG_BOARD_VER_MASK		    0xffff0000
-#define SHARED_HW_CFG_BOARD_VER_SHIFT		    16
-#define SHARED_HW_CFG_BOARD_MAJOR_VER_MASK	    0xf0000000
-#define SHARED_HW_CFG_BOARD_MAJOR_VER_SHIFT	    28
-#define SHARED_HW_CFG_BOARD_MINOR_VER_MASK	    0x0f000000
-#define SHARED_HW_CFG_BOARD_MINOR_VER_SHIFT	    24
-#define SHARED_HW_CFG_BOARD_REV_MASK		    0x00ff0000
+#define SHARED_HW_CFG_BOARD_REV_MASK		    0x00FF0000
 #define SHARED_HW_CFG_BOARD_REV_SHIFT		    16
 
+#define SHARED_HW_CFG_BOARD_MAJOR_VER_MASK	    0x0F000000
+#define SHARED_HW_CFG_BOARD_MAJOR_VER_SHIFT	    24
+
+#define SHARED_HW_CFG_BOARD_MINOR_VER_MASK	    0xF0000000
+#define SHARED_HW_CFG_BOARD_MINOR_VER_SHIFT	    28
+
 	u32 reserved;						/* 0x128 */
 
 };
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 77793bb..f448658 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2505,9 +2505,8 @@ static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
 
 		BNX2X_ERR("SPIO5 hw attention\n");
 
-		switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
-		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1021G:
-		case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
+		switch (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config)) {
+		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 			/* Fan failure attention */
 
 			/* The PHY reset is controlled by GPIO 1 */
@@ -5622,9 +5621,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 		return -EBUSY;
 	}
 
-	switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
-	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1021G:
-	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
+	switch (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config)) {
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 		/* Fan failure is indicated by SPIO 5 */
 		bnx2x_set_spio(bp, MISC_REGISTERS_SPIO_5,
 			       MISC_REGISTERS_SPIO_INPUT_HI_Z);
@@ -5830,9 +5828,8 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	/* Port MCP comes here */
 	/* Port DMAE comes here */
 
-	switch (bp->common.board & SHARED_HW_CFG_BOARD_TYPE_MASK) {
-	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1021G:
-	case SHARED_HW_CFG_BOARD_TYPE_BCM957710A1022G:
+	switch (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config)) {
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101:
 		/* add SPIO 5 to group 0 */
 		val = REG_RD(bp, MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
 		val |= AEU_INPUTS_ATTN_BITS_SPIO5;
@@ -7433,10 +7430,7 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 		BNX2X_ERR("BAD MCP validity signature\n");
 
 	bp->common.hw_config = SHMEM_RD(bp, dev_info.shared_hw_config.config);
-	bp->common.board = SHMEM_RD(bp, dev_info.shared_hw_config.board);
-
-	BNX2X_DEV_INFO("hw_config 0x%08x  board 0x%08x\n",
-		       bp->common.hw_config, bp->common.board);
+	BNX2X_DEV_INFO("hw_config 0x%08x\n", bp->common.hw_config);
 
 	bp->link_params.hw_led_mode = ((bp->common.hw_config &
 					SHARED_HW_CFG_LED_MODE_MASK) >>
-- 
1.5.4.3




