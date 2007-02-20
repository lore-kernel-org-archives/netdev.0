From: linas@austin.ibm.com (Linas Vepstas)
Subject: [PATCH 7/12] spidernet: move medium variable into card struct
Date: Tue, 20 Feb 2007 16:39:13 -0600
Message-ID: <20070220223913.GG28895@austin.ibm.com>
References: <20070220221314.GU923@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	kou.ishizaki@toshiba.co.jp, arnd@arndb.de,
	Jens Osterkamp <jens@de.ibm.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:42316 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030501AbXBTWjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 17:39:17 -0500
Content-Disposition: inline
In-Reply-To: <20070220221314.GU923@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Jens Osterkamp <jens@de.ibm.com>

This moves the medium variable into the spidernet card structure.
It renames the GMII_ variables to BCM54XX specific ones.

Signed-off-by: Jens Osterkamp <jens@de.ibm.com>
Signed-off-by: Linas Vepstas <linas@austin.ibm.com>

----
 drivers/net/spider_net.c |   14 +++++++-------
 drivers/net/spider_net.h |    2 ++
 2 files changed, 9 insertions(+), 7 deletions(-)

Index: linux-2.6.20-git16/drivers/net/spider_net.c
===================================================================
--- linux-2.6.20-git16.orig/drivers/net/spider_net.c	2007-02-20 15:02:40.000000000 -0600
+++ linux-2.6.20-git16/drivers/net/spider_net.c	2007-02-20 15:02:42.000000000 -0600
@@ -1909,26 +1909,26 @@ static void spider_net_link_phy(unsigned
 
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
 
Index: linux-2.6.20-git16/drivers/net/spider_net.h
===================================================================
--- linux-2.6.20-git16.orig/drivers/net/spider_net.h	2007-02-20 15:02:38.000000000 -0600
+++ linux-2.6.20-git16/drivers/net/spider_net.h	2007-02-20 15:02:42.000000000 -0600
@@ -444,6 +444,8 @@ struct spider_net_card {
 	struct pci_dev *pdev;
 	struct mii_phy phy;
 
+	int medium;
+
 	void __iomem *regs;
 
 	struct spider_net_descr_chain tx_chain;
