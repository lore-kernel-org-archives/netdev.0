From: Joe Perches <joe@perches.com>
Subject: [PATCH 04/11] drivers/net/mac89x0.c: Use print_mac
Date: Fri, 14 Dec 2007 14:34:05 -0800
Message-ID: <1197671652-32492-4-git-send-email-joe@perches.com>
References: <1197671652-32492-1-git-send-email-joe@perches.com>
 <1197671652-32492-2-git-send-email-joe@perches.com>
 <1197671652-32492-3-git-send-email-joe@perches.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4984 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755724AbXLNWeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2007 17:34:17 -0500
In-Reply-To: <1197671652-32492-3-git-send-email-joe@perches.com>
Message-Id: <956426131a609b9dcdce1711c5727c16d68fdf28.1197671367.git.joe@perches.com>
In-Reply-To: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
References: <9fc484fc034428ab68ecb2711c8456df9e98d56d.1197671367.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/mac89x0.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/mac89x0.c b/drivers/net/mac89x0.c
index a19b595..45b56ca 100644
--- a/drivers/net/mac89x0.c
+++ b/drivers/net/mac89x0.c
@@ -584,11 +584,12 @@ static void set_multicast_list(struct net_device *dev)
 
 static int set_mac_address(struct net_device *dev, void *addr)
 {
+	DECLARE_MAC_BUF(mac);
 	int i;
-	printk("%s: Setting MAC address to ", dev->name);
 	for (i = 0; i < 6; i++)
-		printk(" %2.2x", dev->dev_addr[i] = ((unsigned char *)addr)[i]);
-	printk(".\n");
+		dev->dev_addr[i] = ((unsigned char *)addr)[i];
+	printk(KERN_INFO "%s: Setting MAC address to %s\n",
+	       dev->name, print_mac(mac, dev->dev_addr));
 	/* set the Ethernet address */
 	for (i=0; i < ETH_ALEN/2; i++)
 		writereg(dev, PP_IA+i*2, dev->dev_addr[i*2] | (dev->dev_addr[i*2+1] << 8));
-- 
1.5.3.7.949.g2221a6

