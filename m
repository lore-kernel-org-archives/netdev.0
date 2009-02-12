From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 18/41]bnx2x: EMAC reset
Date: Thu, 12 Feb 2009 20:37:04 +0200
Message-ID: <1234463824.1863.150.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2941 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756079AbZBLSpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:07 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 18/41]bnx2x: EMAC reset
The NIG_ENABLE does not reset the emac. Replace it with explicit reset

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_link.c |    6 ++++--
 drivers/net/bnx2x_reg.h  |    2 ++
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index ffa412f..f4c699e 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -297,8 +297,10 @@ static u8 bnx2x_emac_enable(struct link_params *params,
 			   port*4, 0);
 	}
 
-	/* enable emac */
-	REG_WR(bp, NIG_REG_NIG_EMAC0_EN + port*4, 1);
+	bnx2x_bits_en(bp, emac_base + EMAC_REG_EMAC_RX_MODE,
+		    EMAC_RX_MODE_RESET);
+	bnx2x_bits_en(bp, emac_base + EMAC_REG_EMAC_TX_MODE,
+		    EMAC_TX_MODE_RESET);
 
 	if (CHIP_REV_IS_SLOW(bp)) {
 		/* config GMII mode */
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 5cfeac9..b6c9249 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -5173,9 +5173,11 @@
 #define EMAC_RX_MODE_FLOW_EN					 (1L<<2)
 #define EMAC_RX_MODE_KEEP_VLAN_TAG				 (1L<<10)
 #define EMAC_RX_MODE_PROMISCUOUS				 (1L<<8)
+#define EMAC_RX_MODE_RESET					 (1L<<0)
 #define EMAC_RX_MTU_SIZE_JUMBO_ENA				 (1L<<31)
 #define EMAC_TX_MODE_EXT_PAUSE_EN				 (1L<<3)
 #define EMAC_TX_MODE_FLOW_EN					 (1L<<4)
+#define EMAC_TX_MODE_RESET					 (1L<<0)
 #define MISC_REGISTERS_GPIO_0					 0
 #define MISC_REGISTERS_GPIO_1					 1
 #define MISC_REGISTERS_GPIO_2					 2
-- 
1.5.4.3




