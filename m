From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb3: minor aq100x phy fixes
Date: Wed, 03 Jun 2009 09:19:15 -0700
Message-ID: <20090603161915.17960.58081.stgit@speedy5>
References: <20090603161910.17960.28171.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:27924 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755456AbZFCQTP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jun 2009 12:19:15 -0400
In-Reply-To: <20090603161910.17960.28171.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Use generic MDIO generic values.
Based on Ben Hutchings'review comments.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/aq100x.c |   24 ++++++++++++------------
 1 files changed, 12 insertions(+), 12 deletions(-)


diff --git a/drivers/net/cxgb3/aq100x.c b/drivers/net/cxgb3/aq100x.c
index c51e50d..b1fd5bf 100644
--- a/drivers/net/cxgb3/aq100x.c
+++ b/drivers/net/cxgb3/aq100x.c
@@ -43,8 +43,6 @@ enum {
 	AQ_XAUI_TX_CFG	= 0xe400,
 
 	/* MDIO_DEV_ANEG registers */
-	AQ_100M_CTRL	= 0x0010,
-	AQ_10G_CTRL	= 0x0020,
 	AQ_1G_CTRL	= 0xc400,
 	AQ_ANEG_STAT	= 0xc800,
 
@@ -54,14 +52,15 @@ enum {
 	AQ_IMASK_GLOBAL	= 0xff00,
 };
 
-#define AQBIT(x)	(1 << (x))
-#define IMASK_PMA	AQBIT(0x2)
-#define IMASK_GLOBAL	AQBIT(0xf)
-#define ADV_1G_FULL	AQBIT(0xf)
-#define ADV_1G_HALF	AQBIT(0xe)
-#define ADV_10G_FULL	AQBIT(0xc)
-#define AQ_RESET	(AQBIT(0xe) | AQBIT(0xf))
-#define AQ_LOWPOWER	AQBIT(0xb)
+enum {
+	IMASK_PMA	= 1 << 2,
+	IMASK_GLOBAL	= 1 << 15,
+	ADV_1G_FULL	= 1 << 15,
+	ADV_1G_HALF	= 1 << 14,
+	ADV_10G_FULL	= 1 << 12,
+	AQ_RESET	= (1 << 14) | (1 << 15),
+	AQ_LOWPOWER	= 1 << 12,
+};
 
 static int aq100x_reset(struct cphy *phy, int wait)
 {
@@ -160,7 +159,7 @@ static int aq100x_advertise(struct cphy *phy, unsigned int advertise_map)
 	adv = 0;
 	if (advertise_map & ADVERTISED_10000baseT_Full)
 		adv |= ADV_10G_FULL;
-	err = t3_mdio_change_bits(phy, MDIO_MMD_AN, AQ_10G_CTRL,
+	err = t3_mdio_change_bits(phy, MDIO_MMD_AN, MDIO_AN_10GBT_CTRL,
 				  ADV_10G_FULL, adv);
 	if (err)
 		return err;
@@ -186,7 +185,8 @@ static int aq100x_advertise(struct cphy *phy, unsigned int advertise_map)
 		adv |= ADVERTISE_PAUSE_CAP;
 	if (advertise_map & ADVERTISED_Asym_Pause)
 		adv |= ADVERTISE_PAUSE_ASYM;
-	err = t3_mdio_change_bits(phy, MDIO_MMD_AN, AQ_100M_CTRL, 0xfe0, adv);
+	err = t3_mdio_change_bits(phy, MDIO_MMD_AN, MDIO_AN_ADVERTISE,
+				  0xfe0, adv);
 
 	return err;
 }

