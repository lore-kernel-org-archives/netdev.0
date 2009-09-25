From: Sriram <srk@ti.com>
Subject: [PATCH] TI Davinci EMAC: Fix in vector definition for EMAC_VERSION_2
Date: Fri, 25 Sep 2009 10:45:18 +0530
Message-ID: <1253855718-6871-1-git-send-email-srk@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com, Sriram <srk@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:44288 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955AbZIYFPW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Sep 2009 01:15:22 -0400
Received: from dbdp31.itg.ti.com ([172.24.170.98])
	by bear.ext.ti.com (8.13.7/8.13.7) with ESMTP id n8P5FNI9019402
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 25 Sep 2009 00:15:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the emac_poll function when looking for interrupt status masks
correct definition must be chosen based on EMAC_VERSION(the bit
mask has changed from version 1 to version 2).

Signed-off-by: Sriram <srk@ti.com>
Acked-by: Chaithrika U S <chaithrika@ti.com>
---
 drivers/net/davinci_emac.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 12fd446..376f527 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -200,6 +200,9 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 /** NOTE:: For DM646x the IN_VECTOR has changed */
 #define EMAC_DM646X_MAC_IN_VECTOR_RX_INT_VEC	BIT(EMAC_DEF_RX_CH)
 #define EMAC_DM646X_MAC_IN_VECTOR_TX_INT_VEC	BIT(16 + EMAC_DEF_TX_CH)
+#define EMAC_DM646X_MAC_IN_VECTOR_HOST_INT	BIT(26)
+#define EMAC_DM646X_MAC_IN_VECTOR_STATPEND_INT	BIT(27)
+
 
 /* CPPI bit positions */
 #define EMAC_CPPI_SOP_BIT		BIT(31)
@@ -2168,7 +2171,11 @@ static int emac_poll(struct napi_struct *napi, int budget)
 		emac_int_enable(priv);
 	}
 
-	if (unlikely(status & EMAC_DM644X_MAC_IN_VECTOR_HOST_INT)) {
+	mask = EMAC_DM644X_MAC_IN_VECTOR_HOST_INT;
+	if (priv->version == EMAC_VERSION_2)
+		mask = EMAC_DM646X_MAC_IN_VECTOR_HOST_INT;
+
+	if (unlikely(status & mask)) {
 		u32 ch, cause;
 		dev_err(emac_dev, "DaVinci EMAC: Fatal Hardware Error\n");
 		netif_stop_queue(ndev);
-- 
1.6.2.4

