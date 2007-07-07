From: "Michael Chan" <mchan@broadcom.com>
Subject: [2.6.23 2/9][BNX2]: Add remote PHY bit definitions.
Date: Fri, 06 Jul 2007 20:29:17 -0700
Message-ID: <1183778957.5182.19.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2389 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752993AbXGGChA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 22:37:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add remote PHY bit definitions.

Add new fields in struct bnx2 and other bit definitions in shared
memory to support remote PHY.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 49a5de2..14c0a1e 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6537,6 +6537,7 @@ struct bnx2 {
 #define PHY_INT_MODE_AUTO_POLLING_FLAG	0x100
 #define PHY_INT_MODE_LINK_READY_FLAG	0x200
 #define PHY_DIS_EARLY_DAC_FLAG		0x400
+#define REMOTE_PHY_CAP_FLAG		0x800
 
 	u32			mii_bmcr;
 	u32			mii_bmsr;
@@ -6625,6 +6626,7 @@ struct bnx2 {
 	u16			req_line_speed;
 	u8			req_duplex;
 
+	u8			phy_port;
 	u8			link_up;
 
 	u16			line_speed;
@@ -6770,7 +6772,7 @@ struct fw_info {
  * the firmware has timed out, the driver will assume there is no firmware
  * running and there won't be any firmware-driver synchronization during a
  * driver reset. */
-#define FW_ACK_TIME_OUT_MS                  100
+#define FW_ACK_TIME_OUT_MS                  1000
 
 
 #define BNX2_DRV_RESET_SIGNATURE		0x00000000
@@ -6788,6 +6790,7 @@ struct fw_info {
 #define BNX2_DRV_MSG_CODE_DIAG			 0x07000000
 #define BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL	 0x09000000
 #define BNX2_DRV_MSG_CODE_UNLOAD_LNK_DN		 0x0b000000
+#define BNX2_DRV_MSG_CODE_CMD_SET_LINK		 0x10000000
 
 #define BNX2_DRV_MSG_DATA			 0x00ff0000
 #define BNX2_DRV_MSG_DATA_WAIT0			 0x00010000
@@ -6845,6 +6848,30 @@ struct fw_info {
  * This is used for debugging. */
 #define BNX2_DRV_MSG_DATA_PULSE_CODE_ALWAYS_ALIVE	 0x00080000
 
+#define BNX2_DRV_MB_ARG0			0x00000014
+#define BNX2_NETLINK_SET_LINK_SPEED_10HALF	 (1<<0)
+#define BNX2_NETLINK_SET_LINK_SPEED_10FULL	 (1<<1)
+#define BNX2_NETLINK_SET_LINK_SPEED_10		 \
+	(BNX2_NETLINK_SET_LINK_SPEED_10HALF |	 \
+	 BNX2_NETLINK_SET_LINK_SPEED_10FULL)
+#define BNX2_NETLINK_SET_LINK_SPEED_100HALF	 (1<<2)
+#define BNX2_NETLINK_SET_LINK_SPEED_100FULL	 (1<<3)
+#define BNX2_NETLINK_SET_LINK_SPEED_100		 \
+	(BNX2_NETLINK_SET_LINK_SPEED_100HALF |	 \
+	 BNX2_NETLINK_SET_LINK_SPEED_100FULL)
+#define BNX2_NETLINK_SET_LINK_SPEED_1GHALF	 (1<<4)
+#define BNX2_NETLINK_SET_LINK_SPEED_1GFULL	 (1<<5)
+#define BNX2_NETLINK_SET_LINK_SPEED_2G5HALF	 (1<<6)
+#define BNX2_NETLINK_SET_LINK_SPEED_2G5FULL	 (1<<7)
+#define BNX2_NETLINK_SET_LINK_SPEED_10GHALF	 (1<<8)
+#define BNX2_NETLINK_SET_LINK_SPEED_10GFULL	 (1<<9)
+#define BNX2_NETLINK_SET_LINK_ENABLE_AUTONEG	 (1<<10)
+#define BNX2_NETLINK_SET_LINK_PHY_APP_REMOTE	 (1<<11)
+#define BNX2_NETLINK_SET_LINK_FC_SYM_PAUSE	 (1<<12)
+#define BNX2_NETLINK_SET_LINK_FC_ASYM_PAUSE	 (1<<13)
+#define BNX2_NETLINK_SET_LINK_ETH_AT_WIRESPEED	 (1<<14)
+#define BNX2_NETLINK_SET_LINK_PHY_RESET		 (1<<15)
+
 #define BNX2_DEV_INFO_SIGNATURE			0x00000020
 #define BNX2_DEV_INFO_SIGNATURE_MAGIC		 0x44564900
 #define BNX2_DEV_INFO_SIGNATURE_MAGIC_MASK	 0xffffff00
@@ -7065,6 +7092,28 @@ struct fw_info {
 #define BNX2_BC_STATE_BC_DBG_CMD_LOOP_CNT_MASK	 0xffff
 #define BNX2_BC_STATE_BC_DBG_CMD_LOOP_INFINITE	 0xffff
 
+#define BNX2_FW_EVT_CODE_MB			0x354
+#define BNX2_FW_EVT_CODE_SW_TIMER_EXPIRATION_EVENT 0x00000000
+#define BNX2_FW_EVT_CODE_LINK_EVENT		 0x00000001
+
+#define BNX2_DRV_ACK_CAP_MB			0x364
+#define BNX2_DRV_ACK_CAP_SIGNATURE		 0x35450000
+#define BNX2_CAPABILITY_SIGNATURE_MASK		 0xFFFF0000
+
+#define BNX2_FW_CAP_MB				0x368
+#define BNX2_FW_CAP_SIGNATURE			 0xaa550000
+#define BNX2_FW_ACK_DRV_SIGNATURE		 0x52500000
+#define BNX2_FW_CAP_SIGNATURE_MASK		 0xffff0000
+#define BNX2_FW_CAP_REMOTE_PHY_CAPABLE		 0x00000001
+#define BNX2_FW_CAP_REMOTE_PHY_PRESENT		 0x00000002
+
+#define BNX2_RPHY_SIGNATURE			0x36c
+#define BNX2_RPHY_LOAD_SIGNATURE		 0x5a5a5a5a
+
+#define BNX2_RPHY_FLAGS				0x370
+#define BNX2_RPHY_SERDES_LINK			0x374
+#define BNX2_RPHY_COPPER_LINK			0x378
+
 #define HOST_VIEW_SHMEM_BASE			0x167c00
 
 #endif


