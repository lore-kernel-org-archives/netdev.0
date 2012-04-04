From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 08/10] bnx2x: Clear BCM84833 LED after fan failure
Date: Wed, 4 Apr 2012 14:29:01 +0300
Message-ID: <1333538942-9904-9-git-send-email-yanivr@broadcom.com>
References: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2740 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755977Ab2DDJ3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:29:47 -0400
In-Reply-To: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    9 +++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    3 +++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index b576a3a..ce95ef7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9858,6 +9858,15 @@ static int bnx2x_84833_hw_reset_phy(struct bnx2x_phy *phy,
 				other_shmem_base_addr));
 
 	u32 shmem_base_path[2];
+
+	/* Work around for 84833 LED failure inside RESET status */
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
+		MDIO_AN_REG_8481_LEGACY_MII_CTRL,
+		MDIO_AN_REG_8481_MII_CTRL_FORCE_1G);
+	bnx2x_cl45_write(bp, phy, MDIO_AN_DEVAD,
+		MDIO_AN_REG_8481_1G_100T_EXT_CTRL,
+		MIDO_AN_REG_8481_EXT_CTRL_FORCE_LEDS_OFF);
+
 	shmem_base_path[0] = params->shmem_base;
 	shmem_base_path[1] = other_shmem_base_addr;
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 1ea2b95..c25803b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -6821,10 +6821,13 @@ Theotherbitsarereservedandshouldbezero*/
 
 #define MDIO_AN_REG_8481_10GBASE_T_AN_CTRL	0x0020
 #define MDIO_AN_REG_8481_LEGACY_MII_CTRL	0xffe0
+#define MDIO_AN_REG_8481_MII_CTRL_FORCE_1G	0x40
 #define MDIO_AN_REG_8481_LEGACY_MII_STATUS	0xffe1
 #define MDIO_AN_REG_8481_LEGACY_AN_ADV		0xffe4
 #define MDIO_AN_REG_8481_LEGACY_AN_EXPANSION	0xffe6
 #define MDIO_AN_REG_8481_1000T_CTRL		0xffe9
+#define MDIO_AN_REG_8481_1G_100T_EXT_CTRL	0xfff0
+#define MIDO_AN_REG_8481_EXT_CTRL_FORCE_LEDS_OFF	0x0008
 #define MDIO_AN_REG_8481_EXPANSION_REG_RD_RW	0xfff5
 #define MDIO_AN_REG_8481_EXPANSION_REG_ACCESS	0xfff7
 #define MDIO_AN_REG_8481_AUX_CTRL		0xfff8
-- 
1.7.7.1
