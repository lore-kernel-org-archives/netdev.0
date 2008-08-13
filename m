From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 20/25] bnx2x: 1G LED does not turn off
Date: Wed, 13 Aug 2008 17:15:59 +0300
Message-ID: <1218636959.547.96.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3059 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755895AbYHMOQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 10:16:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1G LED does not turn off
The 1G LED was not switched to off when the link was lost

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    1 +
 drivers/net/bnx2x_link.c |    9 +++++++++
 2 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index e15ecfb..98d6f85 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -120,6 +120,7 @@
 #define SHMEM_RD(bp, field)		REG_RD(bp, SHMEM_ADDR(bp, field))
 #define SHMEM_WR(bp, field, val)	REG_WR(bp, SHMEM_ADDR(bp, field), val)
 
+#define EMAC_RD(bp, reg)		REG_RD(bp, emac_base + reg)
 #define NIG_WR(reg, val)	REG_WR(bp, reg, val)
 #define EMAC_WR(reg, val)	REG_WR(bp, emac_base + reg, val)
 #define BMAC_WR(reg, val)	REG_WR(bp, GRCBASE_NIG + bmac_addr + reg, val)
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 693efce..876a968 100755
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -3769,6 +3769,8 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 	       u16 hw_led_mode, u32 chip_id)
 {
 	u8 rc = 0;
+	u32 tmp;
+	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
 	DP(NETIF_MSG_LINK, "bnx2x_set_led: port %x, mode %d\n", port, mode);
 	DP(NETIF_MSG_LINK, "speed 0x%x, hw_led_mode 0x%x\n",
 		 speed, hw_led_mode);
@@ -3777,6 +3779,9 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 		REG_WR(bp, NIG_REG_LED_10G_P0 + port*4, 0);
 		REG_WR(bp, NIG_REG_LED_MODE_P0 + port*4,
 			   SHARED_HW_CFG_LED_MAC1);
+
+		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
+		EMAC_WR(EMAC_REG_EMAC_LED, (tmp | EMAC_LED_OVERRIDE));
 		break;
 
 	case LED_MODE_OPER:
@@ -3788,6 +3793,10 @@ u8 bnx2x_set_led(struct bnx2x *bp, u8 port, u8 mode, u32 speed,
 			   LED_BLINK_RATE_VAL);
 		REG_WR(bp, NIG_REG_LED_CONTROL_BLINK_RATE_ENA_P0 +
 			   port*4, 1);
+		tmp = EMAC_RD(bp, EMAC_REG_EMAC_LED);
+		EMAC_WR(EMAC_REG_EMAC_LED,
+			    (tmp & (~EMAC_LED_OVERRIDE)));
+
 		if (!CHIP_IS_E1H(bp) &&
 		    ((speed == SPEED_2500) ||
 		     (speed == SPEED_1000) ||
-- 
1.5.3.2




