From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] r8169: Fix iteration variable sign
Date: Wed, 29 Nov 2006 22:21:33 +0100
Message-ID: <20061129212133.GB18057@electric-eye.fr.zoreil.com>
References: <200611292048.45152.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	Andrew Morton <akpm@osdl.org>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:50348 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1758110AbWK2VWo
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 16:22:44 -0500
To: torvalds@osdl.org
Content-Disposition: inline
In-Reply-To: <200611292048.45152.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This changes the type of variable "i" in rtl8169_init_one()
from "unsigned int" to "int". "i" is checked for < 0 later,
which can never happen for "unsigned". This results in broken
error handling.
    
Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5002673..c8fa9b1 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1491,8 +1491,8 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	struct rtl8169_private *tp;
 	struct net_device *dev;
 	void __iomem *ioaddr;
-	unsigned int i, pm_cap;
-	int rc;
+	unsigned int pm_cap;
+	int i, rc;
 
 	if (netif_msg_drv(&debug)) {
 		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",
