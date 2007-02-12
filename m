From: Jens Osterkamp <jens@de.ibm.com>
Subject: [PATCH] spidernet: move medium variable into card struct
Date: Mon, 12 Feb 2007 21:37:15 +0100
Message-ID: <200702122137.15309.jens@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, Linas Vepstas <linas@austin.ibm.com>,
	James K Lewis <jim@jklewis.com>,
	Ishizaki Kou <kou.ishizaki@toshiba.co.jp>,
	netdev@vger.kernel.org, cbe-oss-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:34038 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965380AbXBLUhQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Feb 2007 15:37:16 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l1CKbFNX078762
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 20:37:15 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1CKbF6F868586
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 20:37:15 GMT
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1CKbERO004886
	for <netdev@vger.kernel.org>; Mon, 12 Feb 2007 20:37:15 GMT
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This moves the medium variable into the spidernet card structure.
It renames the GMII_ variables to BCM54XX specific ones.

Signed-off-by: Jens Osterkamp <jens@de.ibm.com>

---

Index: linux-2.6.20/drivers/net/spider_net.c
===================================================================
--- linux-2.6.20.orig/drivers/net/spider_net.c
+++ linux-2.6.20/drivers/net/spider_net.c
@@ -1912,26 +1912,26 @@ static void spider_net_link_phy(unsigned
 
 		pr_info("%s: link is down trying to bring it up\n", card->netdev->name);
 
-		switch (phy->medium) {
-		case GMII_COPPER:
+		switch (card->medium) {
+		case BCM54XX_COPPER:
 			/* enable fiber with autonegotiation first */
 			if (phy->def->ops->enable_fiber)
 				phy->def->ops->enable_fiber(phy, 1);
-			phy->medium = GMII_FIBER;
+			card->medium = BCM54XX_FIBER;
 			break;
 
-		case GMII_FIBER:
+		case BCM54XX_FIBER:
 			/* fiber didn't come up, try to disable fiber autoneg */
 			if (phy->def->ops->enable_fiber)
 				phy->def->ops->enable_fiber(phy, 0);
-			phy->medium = GMII_UNKNOWN;
+			card->medium = BCM54XX_UNKNOWN;
 			break;
 
-		case GMII_UNKNOWN:
+		case BCM54XX_UNKNOWN:
 			/* copper, fiber with and without failed,
 			 * retry from beginning */
 			spider_net_setup_aneg(card);
-			phy->medium = GMII_COPPER;
+			card->medium = BCM54XX_COPPER;
 			break;
 		}
 
Index: linux-2.6.20/drivers/net/spider_net.h
===================================================================
--- linux-2.6.20.orig/drivers/net/spider_net.h
+++ linux-2.6.20/drivers/net/spider_net.h
@@ -444,6 +444,8 @@ struct spider_net_card {
 	struct pci_dev *pdev;
 	struct mii_phy phy;
 
+	int medium;
+
 	void __iomem *regs;
 
 	struct spider_net_descr_chain tx_chain;
