From: Joe Perches <joe@perches.com>
Subject: [PATCH 02/11] drivers/net/hplance.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:03 -0800
Message-ID: <b58808ccb17be357af117065d60049ce06907096.1197671367.git.joe__23456.8272521303$1197671781$gmane$org@perches.com>
References: <1197671652-32492-1-git-send-email-joe@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4980 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558AbXLNWeQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 17:34:16 -0500
In-Reply-To: <1197671652-32492-1-git-send-email-joe@perches.com>
Message-Id: <b58808ccb17be357af117065d60049ce06907096.1197671367.git.joe@perches.com>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/hplance.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hplance.c b/drivers/net/hplance.c
index be6e5bc..2748b47 100644
--- a/drivers/net/hplance.c
+++ b/drivers/net/hplance.c
@@ -77,7 +77,7 @@ static int __devinit hplance_init_one(struct dio_dev *d,
 {
 	struct net_device *dev;
 	int err = -ENOMEM;
-	int i;
+	DECLARE_MAC_BUF(mac);
 
 	dev = alloc_etherdev(sizeof(struct hplance_private));
 	if (!dev)
@@ -95,13 +95,9 @@ static int __devinit hplance_init_one(struct dio_dev *d,
 
 	dio_set_drvdata(d, dev);
 
-	printk(KERN_INFO "%s: %s; select code %d, addr %2.2x", dev->name, d->name, d->scode, dev->dev_addr[0]);
-
-	for (i=1; i<6; i++) {
-		printk(":%2.2x", dev->dev_addr[i]);
-	}
-
-	printk(", irq %d\n", d->ipl);
+	printk(KERN_INFO "%s: %s; select code %d, addr %s, irq %d\n",
+	       dev->name, d->name, d->scode,
+	       print_mac(mac, dev->dev_addr), d->irq);
 
 	return 0;
 
-- 
1.5.3.7.949.g2221a6

