From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 08/10] bnx2x: Fix BCM54618se invalid link indication
Date: Wed, 3 Aug 2011 12:00:00 +0300
Message-ID: <1312362000.21665.98.camel@lb-tlvb-dmitry.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1083 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753306Ab1HCJAM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2011 05:00:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After resetting BCM54618se, link partner would still see link since the PHY wasn't put into low-power state.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index cf8b8d1..5e6f351 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -10219,8 +10219,15 @@ static void bnx2x_54618se_link_reset(struct bnx2x_phy *phy,
 	u32 cfg_pin;
 	u8 port;
 
-	/* This works with E3 only, no need to check the chip
-	   before determining the port. */
+	/*
+	 * In case of no EPIO routed to reset the GPHY, put it
+	 * in low power mode.
+	 */
+	bnx2x_cl22_write(bp, phy, MDIO_PMA_REG_CTRL, 0x800);
+	/*
+	 * This works with E3 only, no need to check the chip
+	 * before determining the port.
+	 */
 	port = params->port;
 	cfg_pin = (REG_RD(bp, params->shmem_base +
 			offsetof(struct shmem_region,
-- 
1.7.1





