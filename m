From: "Michael Chan" <mchan@broadcom.com>
Subject: [TG3 6/8]: Use constant for PHY register 0x1e.
Date: Tue, 13 Feb 2007 12:14:43 -0800
Message-ID: <1171397683.18944.30.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3531 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751806AbXBMTbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 14:31:21 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Use constant for PHY register 0x1e.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 604f308..a1aeba2 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6594,8 +6594,9 @@ static int tg3_reset_hw(struct tg3 *tp,
 		u32 tmp;
 
 		/* Clear CRC stats. */
-		if (!tg3_readphy(tp, 0x1e, &tmp)) {
-			tg3_writephy(tp, 0x1e, tmp | 0x8000);
+		if (!tg3_readphy(tp, MII_TG3_TEST1, &tmp)) {
+			tg3_writephy(tp, MII_TG3_TEST1,
+				     tmp | MII_TG3_TEST1_CRC_EN);
 			tg3_readphy(tp, 0x14, &tmp);
 		}
 	}
@@ -7419,8 +7420,9 @@ static unsigned long calc_crc_errors(str
 		u32 val;
 
 		spin_lock_bh(&tp->lock);
-		if (!tg3_readphy(tp, 0x1e, &val)) {
-			tg3_writephy(tp, 0x1e, val | 0x8000);
+		if (!tg3_readphy(tp, MII_TG3_TEST1, &val)) {
+			tg3_writephy(tp, MII_TG3_TEST1,
+				     val | MII_TG3_TEST1_CRC_EN);
 			tg3_readphy(tp, 0x14, &val);
 		} else
 			val = 0;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index 80f59ac..45d477e 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1660,6 +1660,7 @@
 
 #define MII_TG3_TEST1			0x1e
 #define MII_TG3_TEST1_TRIM_EN		0x0010
+#define MII_TG3_TEST1_CRC_EN		0x8000
 
 /* There are two ways to manage the TX descriptors on the tigon3.
  * Either the descriptors are in host DMA'able memory, or they


