From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 04/10] bnx2x: Fix compilation warning messages
Date: Mon, 31 Jan 2011 16:22:03 +0200
Message-ID: <1296483723.17181.114.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1577 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853Ab1AaOZB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 09:25:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix annoying compilation warning, mainly related to static declarations

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   18 ++++++------------
 drivers/net/bnx2x/bnx2x_link.h |    5 +++++
 2 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 0d8b5b1..a394092 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -183,12 +183,6 @@
 		(_bank + (_addr & 0xf)), \
 		_val)
 
-static u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
-			  u8 devad, u16 reg, u16 *ret_val);
-
-static u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
-			   u8 devad, u16 reg, u16 val);
-
 static u32 bnx2x_bits_en(struct bnx2x *bp, u32 reg, u32 bits)
 {
 	u32 val = REG_RD(bp, reg);
@@ -269,7 +263,7 @@ void bnx2x_ets_disabled(struct link_params *params)
 	REG_WR(bp, PBF_REG_NUM_STRICT_ARB_SLOTS, 0);
 }
 
-void bnx2x_ets_bw_limit_common(const struct link_params *params)
+static void bnx2x_ets_bw_limit_common(const struct link_params *params)
 {
 	/* ETS disabled configuration */
 	struct bnx2x *bp = params->bp;
@@ -1391,8 +1385,8 @@ static u32 bnx2x_get_emac_base(struct bnx2x *bp,
 /******************************************************************/
 /*			CL45 access functions			  */
 /******************************************************************/
-u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
-		    u8 devad, u16 reg, u16 val)
+static u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
+			   u8 devad, u16 reg, u16 val)
 {
 	u32 tmp, saved_mode;
 	u8 i, rc = 0;
@@ -1458,8 +1452,8 @@ u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 	return rc;
 }
 
-u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
-		   u8 devad, u16 reg, u16 *ret_val)
+static u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
+			  u8 devad, u16 reg, u16 *ret_val)
 {
 	u32 val, saved_mode;
 	u16 i;
@@ -4658,7 +4652,7 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 		DP(NETIF_MSG_LINK,
 			 "Got bad status 0x%x when reading from SFP+ EEPROM\n",
 			 (val & MDIO_PMA_REG_SFP_TWO_WIRE_CTRL_STATUS_MASK));
-		return -EINVAL;
+		return -EFAULT;
 	}
 
 	/* Read the buffer */
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index d9e847b..92f36b6 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -337,6 +337,11 @@ void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port);
 /* Reset the external of SFX7101 */
 void bnx2x_sfx7101_sp_sw_reset(struct bnx2x *bp, struct bnx2x_phy *phy);
 
+/* Read "byte_cnt" bytes from address "addr" from the SFP+ EEPROM */
+u8 bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
+				struct link_params *params, u16 addr,
+				u8 byte_cnt, u8 *o_buf);
+
 void bnx2x_hw_reset_phy(struct link_params *params);
 
 /* Checks if HW lock is required for this phy/board type */
-- 
1.7.1







