From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH 06/12] fec: refactor set_multicast_list() to make it more readable
Date: Wed, 15 Apr 2009 13:32:19 +0200
Message-ID: <1239795145-27558-7-git-send-email-s.hauer@pengutronix.de>
References: <1239795145-27558-1-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-2-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-3-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-4-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-5-git-send-email-s.hauer@pengutronix.de>
 <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:37890 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755144AbZDOLd7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2009 07:33:59 -0400
In-Reply-To: <1239795145-27558-6-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   99 +++++++++++++++++++++++++++-------------------------
 1 files changed, 51 insertions(+), 48 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index ab8e66b..b72df48 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1518,57 +1518,60 @@ static void set_multicast_list(struct net_device *dev)
 		tmp = readl(fep->hwp + FEC_R_CNTRL);
 		tmp |= 0x8;
 		writel(tmp, fep->hwp + FEC_R_CNTRL);
-	} else {
-		tmp = readl(fep->hwp + FEC_R_CNTRL);
-		tmp &= ~0x8;
-		writel(tmp, fep->hwp + FEC_R_CNTRL);
+		return;
+	}
 
-		if (dev->flags & IFF_ALLMULTI) {
-			/* Catch all multicast addresses, so set the
-			 * filter to all 1's
-			 */
-			writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-			writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-		} else {
-			/* Clear filter and add the addresses in hash register
-			 */
-			writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-			writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-
-			dmi = dev->mc_list;
-
-			for (j = 0; j < dev->mc_count; j++, dmi = dmi->next) {
-				/* Only support group multicast for now */
-				if (!(dmi->dmi_addr[0] & 1))
-					continue;
-
-				/* calculate crc32 value of mac address */
-				crc = 0xffffffff;
-
-				for (i = 0; i < dmi->dmi_addrlen; i++) {
-					data = dmi->dmi_addr[i];
-					for (bit = 0; bit < 8; bit++, data >>= 1) {
-						crc = (crc >> 1) ^
-						(((crc ^ data) & 1) ? CRC32_POLY : 0);
-					}
-				}
-
-				/* only upper 6 bits (HASH_BITS) are used
-				 * which point to specific bit in he hash registers
-				 */
-				hash = (crc >> (32 - HASH_BITS)) & 0x3f;
-
-				if (hash > 31) {
-					tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-					tmp |= 1 << (hash - 32);
-					writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
-				} else {
-					tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-					tmp |= 1 << hash;
-					writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
-				}
+	tmp = readl(fep->hwp + FEC_R_CNTRL);
+	tmp &= ~0x8;
+	writel(tmp, fep->hwp + FEC_R_CNTRL);
+
+	if (dev->flags & IFF_ALLMULTI) {
+		/* Catch all multicast addresses, so set the
+		 * filter to all 1's
+		 */
+		writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+		writel(0xffffffff, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+
+		return;
+	}
+
+	/* Clear filter and add the addresses in hash register
+	 */
+	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+	writel(0, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+
+	dmi = dev->mc_list;
+
+	for (j = 0; j < dev->mc_count; j++, dmi = dmi->next) {
+		/* Only support group multicast for now */
+		if (!(dmi->dmi_addr[0] & 1))
+			continue;
+
+		/* calculate crc32 value of mac address */
+		crc = 0xffffffff;
+
+		for (i = 0; i < dmi->dmi_addrlen; i++) {
+			data = dmi->dmi_addr[i];
+			for (bit = 0; bit < 8; bit++, data >>= 1) {
+				crc = (crc >> 1) ^
+				(((crc ^ data) & 1) ? CRC32_POLY : 0);
 			}
 		}
+
+		/* only upper 6 bits (HASH_BITS) are used
+		 * which point to specific bit in he hash registers
+		 */
+		hash = (crc >> (32 - HASH_BITS)) & 0x3f;
+
+		if (hash > 31) {
+			tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+			tmp |= 1 << (hash - 32);
+			writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_HIGH);
+		} else {
+			tmp = readl(fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+			tmp |= 1 << hash;
+			writel(tmp, fep->hwp + FEC_GRP_HASH_TABLE_LOW);
+		}
 	}
 }
 
-- 
1.6.2.1

