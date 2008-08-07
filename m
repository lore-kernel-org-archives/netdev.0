From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH] e100: Use pci_pme_active to clear PME_Status and disable PME#
Date: Fri, 8 Aug 2008 00:18:04 +0200
Message-ID: <200808080018.05887.rjw@sisk.pl>
References: <200808051730.27599.alessandro.guido@gmail.com> <200808080000.07156.rjw@sisk.pl> <200808080014.25493.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alessandro Guido <alessandro.guido@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pm list <linux-pm@lists.linux-foundation.org>,
	Jeff Garzik <jeff@garzik.org>
To: Jesse Barnes <jbarnes@virtuousgeek.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:37033 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753753AbYHGWPK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Aug 2008 18:15:10 -0400
In-Reply-To: <200808080014.25493.rjw@sisk.pl>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e100: Use pci_pme_active to clear PME_Status and disable PME#

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

---
 drivers/net/e100.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

Index: linux-2.6/drivers/net/e100.c
===================================================================
--- linux-2.6.orig/drivers/net/e100.c
+++ linux-2.6/drivers/net/e100.c
@@ -2738,9 +2738,7 @@ static int __devinit e100_probe(struct p
 		nic->flags |= wol_magic;
 
 	/* ack any pending wake events, disable PME */
-	err = pci_enable_wake(pdev, 0, 0);
-	if (err)
-		DPRINTK(PROBE, ERR, "Error clearing wake event\n");
+	pci_pme_active(pdev, false);
 
 	strcpy(netdev->name, "eth%d");
 	if((err = register_netdev(netdev))) {
