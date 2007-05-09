From: Ishizaki Kou <kou.ishizaki@toshiba.co.jp>
Subject: [PATCH] spidernet: remove unnecessary accesses to phy
Date: Wed, 09 May 2007 16:30:07 +0900 (JST)
Message-ID: <200705090730.l497UH3H003138@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: linas@austin.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from imx9.toshiba.co.jp ([202.33.96.51]:41644 "EHLO
	imx9.toshiba.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbXEIHpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 03:45:35 -0400
Received: from inet-tsb5.toshiba.co.jp (inet-tsb5 [202.33.96.24])
	by imx9.toshiba.co.jp  with ESMTP id l497jTow021212
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 9 May 2007 16:45:29 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch removes unnecessary accesses to phy registers.

Signed-off-by: Kou Ishizaki <kou.ishizaki@toshiba.co.jp>
---

Index: linux-powerpc-git/drivers/net/spider_net.c
diff -u linux-powerpc-git/drivers/net/spider_net.c:1.1.1.9 linux-powerpc-git/drivers/net/spider_net.c:1.14
--- linux-powerpc-git/drivers/net/spider_net.c:1.1.1.9	Tue May  8 09:41:28 2007
+++ linux-powerpc-git/drivers/net/spider_net.c	Tue May  8 10:16:59 2007
@@ -175,12 +175,10 @@
 {
 	struct mii_phy *phy = &card->phy;
 	u32 advertise = 0;
-	u16 bmcr, bmsr, stat1000, estat;
+	u16 bmsr, estat;
 
-	bmcr     = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMCR);
-	bmsr     = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
-	stat1000 = spider_net_read_phy(card->netdev, phy->mii_id, MII_STAT1000);
-	estat    = spider_net_read_phy(card->netdev, phy->mii_id, MII_ESTATUS);
+	bmsr  = spider_net_read_phy(card->netdev, phy->mii_id, MII_BMSR);
+	estat = spider_net_read_phy(card->netdev, phy->mii_id, MII_ESTATUS);
 
 	if (bmsr & BMSR_10HALF)
 		advertise |= ADVERTISED_10baseT_Half;
