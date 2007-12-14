From: Joe Perches <joe@perches.com>
Subject: [PATCH 03/11] drivers/net/mac8390.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:04 -0800
Message-ID: <1197671652-32492-3-git-send-email-joe@perches.com>
References: <1197671652-32492-1-git-send-email-joe@perches.com>
 <1197671652-32492-2-git-send-email-joe@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Paul Gortmaker <p_gortmaker@yahoo.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4981 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754753AbXLNWeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 17:34:17 -0500
In-Reply-To: <1197671652-32492-2-git-send-email-joe@perches.com>
Message-Id: <a737529b0fd2d0a3ea1dcdf684e5b869a347726c.1197671367.git.joe@perches.com>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/mac8390.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/mac8390.c b/drivers/net/mac8390.c
index 9e70074..4eccebb 100644
--- a/drivers/net/mac8390.c
+++ b/drivers/net/mac8390.c
@@ -483,6 +483,7 @@ void cleanup_module(void)
 static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * ndev,
 			    enum mac8390_type type)
 {
+	DECLARE_MAC_BUF(mac);
 	static u32 fwrd4_offsets[16]={
 		0,      4,      8,      12,
 		16,     20,     24,     28,
@@ -612,18 +613,11 @@ static int __init mac8390_initdev(struct net_device * dev, struct nubus_dev * nd
 	/* Good, done, now spit out some messages */
 	printk(KERN_INFO "%s: %s in slot %X (type %s)\n",
 		   dev->name, ndev->board->name, ndev->board->slot, cardname[type]);
-	printk(KERN_INFO "MAC ");
-	{
-		int i;
-		for (i = 0; i < 6; i++) {
-			printk("%2.2x", dev->dev_addr[i]);
-			if (i < 5)
-				printk(":");
-		}
-	}
-	printk(" IRQ %d, %d KB shared memory at %#lx,  %d-bit access.\n",
-		   dev->irq, (int)((dev->mem_end - dev->mem_start)/0x1000) * 4,
-		   dev->mem_start, access_bitmode?32:16);
+	printk(KERN_INFO "MAC %s IRQ %d, %d KB shared memory at %#lx, "
+	       "%d-bit access.\n",
+	       print_mac(mac, dev->dev_addr), dev->irq,
+	       (int)((dev->mem_end - dev->mem_start)/0x1000) * 4,
+	       dev->mem_start, access_bitmode?32:16);
 	return 0;
 }
 
-- 
1.5.3.7.949.g2221a6

