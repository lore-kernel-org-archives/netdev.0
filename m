From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 1/2] net: mvneta: rename MVNETA_GMAC2_PSC_ENABLE to MVNETA_GMAC2_PCS_ENABLE
Date: Wed, 26 Mar 2014 00:25:41 +0100
Message-ID: <1395789942-20764-2-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1395789942-20764-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: Gregory Clement <gregory.clement@free-electrons.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	Lior Amsalem <alior@marvell.com>,
	Steve McIntyre <steve@einval.com>,
	linux-arm-kernel@lists.infradead.org, stable@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:50169 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751886AbaCYXZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 19:25:49 -0400
In-Reply-To: <1395789942-20764-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bit 3 of the MVNETA_GMAC_CTRL_2 is actually used to enable the PCS,
not the PSC: there was a typo in the name of the define, which this
commit fixes.

Cc: stable@vger.kernel.org
Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
This patch is needed for a followup commit that fixes using the mvneta
driver as a module in RGMII configurations.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index f418f4f..d6b04d0 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -161,7 +161,7 @@
 #define      MVNETA_GMAC_MAX_RX_SIZE_MASK        0x7ffc
 #define      MVNETA_GMAC0_PORT_ENABLE            BIT(0)
 #define MVNETA_GMAC_CTRL_2                       0x2c08
-#define      MVNETA_GMAC2_PSC_ENABLE             BIT(3)
+#define      MVNETA_GMAC2_PCS_ENABLE             BIT(3)
 #define      MVNETA_GMAC2_PORT_RGMII             BIT(4)
 #define      MVNETA_GMAC2_PORT_RESET             BIT(6)
 #define MVNETA_GMAC_STATUS                       0x2c10
@@ -733,7 +733,7 @@ static void mvneta_port_sgmii_config(struct mvneta_port *pp)
 	u32 val;
 
 	val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
-	val |= MVNETA_GMAC2_PSC_ENABLE;
+	val |= MVNETA_GMAC2_PCS_ENABLE;
 	mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
 
 	mvreg_write(pp, MVNETA_SGMII_SERDES_CFG, MVNETA_SGMII_SERDES_PROTO);
-- 
1.8.3.2
