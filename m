From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] r8169: Fix iteration variable sign
Date: Wed, 29 Nov 2006 20:48:44 +0100
Message-ID: <200611292048.45152.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:36829
	"EHLO vs166246.vserver.de") by vger.kernel.org with ESMTP
	id S967603AbWK2Txt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 14:53:49 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This changes the type of variable "i" in
rtl8169_init_one() from "unsigned int" to "int".
"i" is checked for <0 later, which can never happen
for "unsigned". This results in broken error handling.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: linux-2.6/drivers/net/r8169.c
===================================================================
--- linux-2.6.orig/drivers/net/r8169.c	2006-11-04 19:03:28.000000000 +0100
+++ linux-2.6/drivers/net/r8169.c	2006-11-29 20:41:59.000000000 +0100
@@ -1473,8 +1473,8 @@ rtl8169_init_one(struct pci_dev *pdev, c
 	struct rtl8169_private *tp;
 	struct net_device *dev;
 	void __iomem *ioaddr;
-	unsigned int i, pm_cap;
-	int rc;
+	unsigned int pm_cap;
+	int i, rc;
 
 	if (netif_msg_drv(&debug)) {
 		printk(KERN_INFO "%s Gigabit Ethernet driver %s loaded\n",

-- 
Greetings Michael.
