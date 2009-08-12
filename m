From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 29/36] bnx2x: Using macro for phy address
Date: Wed, 12 Aug 2009 21:24:02 +0300
Message-ID: <1250101442.27379.181.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4884 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754689AbZHLSZF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Aug 2009 14:25:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |  108 ++++++++++++---------------------------------
 drivers/net/bnx2x_link.h |   12 +++--
 drivers/net/bnx2x_main.c |    8 +---
 3 files changed, 39 insertions(+), 89 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 74f4d10..c2b0010 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -1547,10 +1547,7 @@ static u8 bnx2x_ext_phy_resove_fc(struct link_params *params,
 	u8 ret = 0;
 	u32 ext_phy_type;
 	u8 port = params->port;
-	ext_phy_addr = ((params->ext_phy_config &
-			 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-
+	ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 	/* read twice */
 
@@ -2011,9 +2008,8 @@ static void bnx2x_ext_phy_reset(struct link_params *params,
 {
 	struct bnx2x *bp = params->bp;
 	u32 ext_phy_type;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
+
 	DP(NETIF_MSG_LINK, "Port %x: bnx2x_ext_phy_reset\n", params->port);
 	ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 	/* The PHY reset is controled by GPIO 1
@@ -2292,9 +2288,7 @@ static void bnx2x_bcm8072_external_rom_boot(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	/* Need to wait 200ms after reset */
@@ -2342,9 +2336,7 @@ static u8 bnx2x_8073_is_snr_needed(struct link_params *params)
 	/* This is only required for 8073A1, version 102 only */
 
 	struct bnx2x *bp = params->bp;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u16 val;
 
 	/* Read 8073 HW revision*/
@@ -2375,9 +2367,7 @@ static u8 bnx2x_8073_is_snr_needed(struct link_params *params)
 static u8 bnx2x_bcm8073_xaui_wa(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u16 val, cnt, cnt1 ;
 
 	bnx2x_cl45_read(bp, params->port,
@@ -2519,9 +2509,7 @@ static void bnx2x_bcm8726_external_rom_boot(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	/* Need to wait 100ms after reset */
@@ -2607,9 +2595,7 @@ static u8 bnx2x_8726_read_sfp_module_eeprom(struct link_params *params,
 	u16 val = 0;
 	u16 i;
 	u8 port = params->port;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 	if (byte_cnt > 16) {
 		DP(NETIF_MSG_LINK, "Reading from eeprom is"
@@ -2691,9 +2677,7 @@ static u8 bnx2x_8727_read_sfp_module_eeprom(struct link_params *params,
 	struct bnx2x *bp = params->bp;
 	u16 val, i;
 	u8 port = params->port;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	if (byte_cnt > 16) {
@@ -2946,9 +2930,7 @@ static u8 bnx2x_bcm8726_set_limiting_mode(struct link_params *params,
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u16 cur_limiting_mode;
 
 	bnx2x_cl45_read(bp, port,
@@ -3014,9 +2996,7 @@ static u8 bnx2x_bcm8727_set_limiting_mode(struct link_params *params,
 	u8 port = params->port;
 	u16 phy_identifier;
 	u16 rom_ver2_val;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 
 	bnx2x_cl45_read(bp, port,
 		       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727,
@@ -3120,9 +3100,7 @@ static u8 bnx2x_sfp_module_detection(struct link_params *params)
 	struct bnx2x *bp = params->bp;
 	u16 edc_mode;
 	u8 rc = 0;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 	u32 val = REG_RD(bp, params->shmem_base +
 			     offsetof(struct shmem_region, dev_info.
@@ -3212,9 +3190,8 @@ void bnx2x_handle_module_detect_int(struct link_params *params)
 		else
 			DP(NETIF_MSG_LINK, "SFP+ module is not initialized\n");
 	} else {
-		u8 ext_phy_addr = ((params->ext_phy_config &
-				    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+		u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
+
 		u32 ext_phy_type =
 			XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 		u32 val = REG_RD(bp, params->shmem_base +
@@ -3238,9 +3215,7 @@ static void bnx2x_bcm807x_force_10G(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	/* Force KR or KX */
@@ -3266,9 +3241,7 @@ static void bnx2x_bcm8073_set_xaui_low_power_mode(struct link_params *params)
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
 	u16 val;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			     PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	bnx2x_cl45_read(bp, params->port,
@@ -3333,9 +3306,7 @@ static void bnx2x_8073_set_pause_cl37(struct link_params *params,
 
 	struct bnx2x *bp = params->bp;
 	u16 cl37_val;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	bnx2x_cl45_read(bp, params->port,
@@ -3378,9 +3349,7 @@ static void bnx2x_ext_phy_set_pause(struct link_params *params,
 {
 	struct bnx2x *bp = params->bp;
 	u16 val;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 
 	/* read modify write pause advertizing */
@@ -3617,9 +3586,7 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 	u16 val = 0;
 	u8 rc = 0;
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
-		ext_phy_addr = ((params->ext_phy_config &
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+		ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 
 		ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 		/* Make sure that the soft reset is off (expect for the 8072:
@@ -4555,9 +4522,7 @@ static void bnx2x_8727_handle_mod_abs(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 mod_abs, rx_alarm_status;
-	u8 ext_phy_addr = ((params->ext_phy_config &
-			    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+	u8 ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 	u32 val = REG_RD(bp, params->shmem_base +
 			     offsetof(struct shmem_region, dev_info.
 				      port_feature_config[params->port].
@@ -4657,10 +4622,7 @@ static u8 bnx2x_ext_phy_is_link_up(struct link_params *params,
 	u8 ext_phy_link_up = 0;
 	u8 port = params->port;
 	if (vars->phy_flags & PHY_XGXS_FLAG) {
-		ext_phy_addr = ((params->ext_phy_config &
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
-
+		ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 		ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
@@ -5608,10 +5570,8 @@ static void bnx2x_ext_phy_loopback(struct link_params *params)
 
 	if (params->switch_cfg == SWITCH_CFG_10G) {
 		ext_phy_type = XGXS_EXT_PHY_TYPE(params->ext_phy_config);
+		ext_phy_addr = XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 		/* CL37 Autoneg Enabled */
-		ext_phy_addr = ((params->ext_phy_config &
-					PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-					PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
 		switch (ext_phy_type) {
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_DIRECT:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN:
@@ -6180,9 +6140,8 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 		{
 
 			/* Disable Transmitter */
-			u8 ext_phy_addr = ((params->ext_phy_config &
-				    PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				   PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+			u8 ext_phy_addr =
+				XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 			if ((val & PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_MASK) ==
 			    PORT_FEAT_CFG_OPT_MDL_ENFRCMNT_DISABLE_TX_LASER)
 				bnx2x_sfp_set_transmitter(bp, port,
@@ -6200,9 +6159,8 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 			break;
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 		{
-			u8 ext_phy_addr = ((params->ext_phy_config &
-					 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-					 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+			u8 ext_phy_addr =
+				XGXS_EXT_PHY_ADDR(params->ext_phy_config);
 			/* Set soft reset */
 			bnx2x_8726_reset_phy(bp, params->port, ext_phy_addr);
 			break;
@@ -6420,10 +6378,7 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 			      NIG_MASK_SERDES0_LINK_STATUS |
 			      NIG_MASK_MI_INT));
 
-		ext_phy_addr[port] =
-			((ext_phy_config &
-			      PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			      PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+		ext_phy_addr[port] = XGXS_EXT_PHY_ADDR(ext_phy_config);
 
 		/* Need to take the phy out of low power mode in order
 			to write to access its registers */
@@ -6549,9 +6504,7 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 			      NIG_MASK_SERDES0_LINK_STATUS |
 			      NIG_MASK_MI_INT));
 
-		ext_phy_addr[port] = ((ext_phy_config &
-					PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-					PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+		ext_phy_addr[port] = XGXS_EXT_PHY_ADDR(ext_phy_config);
 
 		/* Reset the phy */
 		bnx2x_cl45_write(bp, port,
@@ -6609,10 +6562,7 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 					offsetof(struct shmem_region,
 			dev_info.port_hw_config[port].external_phy_config));
 
-		ext_phy_addr =
-			((ext_phy_config &
-			      PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-			      PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT);
+		ext_phy_addr = XGXS_EXT_PHY_ADDR(ext_phy_config);
 		DP(NETIF_MSG_LINK, "8726_common_init : ext_phy_addr = 0x%x\n",
 			 ext_phy_addr);
 
diff --git a/drivers/net/bnx2x_link.h b/drivers/net/bnx2x_link.h
index e0d7eef..f3e2522 100644
--- a/drivers/net/bnx2x_link.h
+++ b/drivers/net/bnx2x_link.h
@@ -88,10 +88,14 @@ struct link_params {
 
 	u32 lane_config;
 	u32 ext_phy_config;
-#define XGXS_EXT_PHY_TYPE(ext_phy_config)	(ext_phy_config & \
-					PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK)
-#define SERDES_EXT_PHY_TYPE(ext_phy_config)	(ext_phy_config & \
-					PORT_HW_CFG_SERDES_EXT_PHY_TYPE_MASK)
+#define XGXS_EXT_PHY_TYPE(ext_phy_config) \
+		((ext_phy_config) & PORT_HW_CFG_XGXS_EXT_PHY_TYPE_MASK)
+#define XGXS_EXT_PHY_ADDR(ext_phy_config) \
+		(((ext_phy_config) & PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >> \
+		 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT)
+#define SERDES_EXT_PHY_TYPE(ext_phy_config) \
+		((ext_phy_config) & PORT_HW_CFG_SERDES_EXT_PHY_TYPE_MASK)
+
 	/* Phy register parameter */
 	u32 chip_id;
 
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index bcf8362..bdf7228 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -8545,9 +8545,7 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	else if ((ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE) &&
 		 (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN))
 		bp->mdio.prtad =
-			(bp->link_params.ext_phy_config &
-			 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-				PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT;
+			XGXS_EXT_PHY_ADDR(bp->link_params.ext_phy_config);
 
 	val2 = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_upper);
 	val = SHMEM_RD(bp, dev_info.port_hw_config[port].mac_lower);
@@ -9548,9 +9546,7 @@ static int bnx2x_set_eeprom(struct net_device *dev,
 		if (XGXS_EXT_PHY_TYPE(bp->link_params.ext_phy_config) ==
 				       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_SFX7101) {
 			u8 ext_phy_addr =
-				(bp->link_params.ext_phy_config &
-				 PORT_HW_CFG_XGXS_EXT_PHY_ADDR_MASK) >>
-					PORT_HW_CFG_XGXS_EXT_PHY_ADDR_SHIFT;
+			     XGXS_EXT_PHY_ADDR(bp->link_params.ext_phy_config);
 
 			/* DSP Remove Download Mode */
 			bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_0,
-- 
1.5.4.3




