From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] cassini: i reaches 0, not -1.
Date: Mon, 09 Feb 2009 23:12:02 +0100
Message-ID: <4990AA32.1010004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.173]:52308 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbZBIWME (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 17:12:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With while (i-- > 0) { ... } i reaches 0, not -1.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index bbbc3bb..2de2cdf 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -3568,7 +3568,7 @@ static inline void cas_start_dma(struct cas *cp)
 			break;
 		udelay(10);
 	}
-	if (i < 0) txfailed = 1;
+	if (i <= 0) txfailed = 1;
 	i = STOP_TRIES;
 	while (i-- > 0) {
 		val = readl(cp->regs + REG_MAC_RX_CFG);

