From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] sungem: limit reaches -1, but 0 tested
Date: Sat, 31 Jan 2009 13:42:36 +0100
Message-ID: <4984473C.1040508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:61520 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbZAaMmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 Jan 2009 07:42:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With a postfix decrement these reach -1 rather than 0,
but after the loop it is tested to have become 0.

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/sungem_phy.c b/drivers/net/sungem_phy.c
index 61843fd..78f8cee 100644
--- a/drivers/net/sungem_phy.c
+++ b/drivers/net/sungem_phy.c
@@ -79,7 +79,7 @@ static int reset_one_mii_phy(struct mii_phy* phy, int phy_id)
 
 	udelay(100);
 
-	while (limit--) {
+	while (--limit) {
 		val = __phy_read(phy, phy_id, MII_BMCR);
 		if ((val & BMCR_RESET) == 0)
 			break;
