From: Joe Perches <joe@perches.com>
Subject: [PATCH] pcnet_cs: Use pr_fmt and pr_<level>
Date: Sun, 08 Aug 2010 07:50:36 -0700
Message-ID: <1281279036.28761.29.camel@Joe-Laptop.home>
References: <1281270725-25282-1-git-send-email-w.sang@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	David Miller <davem@davemloft.net>
To: Wolfram Sang <w.sang@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2326 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754272Ab0HHOuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Aug 2010 10:50:39 -0400
In-Reply-To: <1281270725-25282-1-git-send-email-w.sang@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It looks as if the printks in get_ax88190 are
incorrect and were duplicated and superceded by a
test in pcnet_config, so I removed them.

Changed the level of the ax88190 test to KERN_NOTICE
to match the other message styles in pcnet_config.

Compiled but untested.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/pcmcia/pcnet_cs.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/pcmcia/pcnet_cs.c b/drivers/net/pcmcia/pcnet_cs.c
index e127923..0542fa4 100644
--- a/drivers/net/pcmcia/pcnet_cs.c
+++ b/drivers/net/pcmcia/pcnet_cs.c
@@ -28,6 +28,8 @@
 
 ======================================================================*/
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/init.h>
@@ -440,8 +442,6 @@ static hw_info_t *get_ax88190(struct pcmcia_device *link)
 	dev->dev_addr[i] = j & 0xff;
 	dev->dev_addr[i+1] = j >> 8;
     }
-    printk(KERN_NOTICE "pcnet_cs: this is an AX88190 card!\n");
-    printk(KERN_NOTICE "pcnet_cs: use axnet_cs instead.\n");
     return NULL;
 }
 
@@ -574,15 +574,15 @@ static int pcnet_config(struct pcmcia_device *link)
 	if ((if_port == 1) || (if_port == 2))
 	    dev->if_port = if_port;
 	else
-	    printk(KERN_NOTICE "pcnet_cs: invalid if_port requested\n");
+	    pr_notice("invalid if_port requested\n");
     } else {
 	dev->if_port = 0;
     }
 
     if ((link->conf.ConfigBase == 0x03c0) &&
 	(link->manf_id == 0x149) && (link->card_id == 0xc1ab)) {
-	printk(KERN_INFO "pcnet_cs: this is an AX88190 card!\n");
-	printk(KERN_INFO "pcnet_cs: use axnet_cs instead.\n");
+	pr_notice("this is an AX88190 card!\n");
+	pr_notice("use axnet_cs instead.\n");
 	goto failed;
     }
 
@@ -597,8 +597,8 @@ static int pcnet_config(struct pcmcia_device *link)
 	local_hw_info = get_hwired(link);
 
     if (local_hw_info == NULL) {
-	printk(KERN_NOTICE "pcnet_cs: unable to read hardware net"
-	       " address for io base %#3lx\n", dev->base_addr);
+	pr_notice("unable to read hardware net address for io base %#3lx\n",
+		  dev->base_addr);
 	goto failed;
     }
 
@@ -640,7 +640,7 @@ static int pcnet_config(struct pcmcia_device *link)
     SET_NETDEV_DEV(dev, &link->dev);
 
     if (register_netdev(dev) != 0) {
-	printk(KERN_NOTICE "pcnet_cs: register_netdev() failed\n");
+	pr_notice("register_netdev() failed\n");
 	goto failed;
     }
 
@@ -649,16 +649,16 @@ static int pcnet_config(struct pcmcia_device *link)
 	netdev_info(dev, "NE2000 (DL100%d rev %02x): ",
 	       (info->flags & IS_DL10022) ? 22 : 19, id);
 	if (info->pna_phy)
-	    printk("PNA, ");
+	    pr_cont("PNA, ");
     } else {
 	netdev_info(dev, "NE2000 Compatible: ");
     }
-    printk("io %#3lx, irq %d,", dev->base_addr, dev->irq);
+    pr_cont("io %#3lx, irq %d,", dev->base_addr, dev->irq);
     if (info->flags & USE_SHMEM)
-	printk (" mem %#5lx,", dev->mem_start);
+	pr_cont(" mem %#5lx,", dev->mem_start);
     if (info->flags & HAS_MISC_REG)
-	printk(" %s xcvr,", if_names[dev->if_port]);
-    printk(" hw_addr %pM\n", dev->dev_addr);
+	pr_cont(" %s xcvr,", if_names[dev->if_port]);
+    pr_cont(" hw_addr %pM\n", dev->dev_addr);
     return 0;
 
 failed:


