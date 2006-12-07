From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/7][TG3]: Identify Serdes devices more clearly.
Date: Wed, 06 Dec 2006 23:47:23 -0800
Message-ID: <1165477643.8488.33.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3299 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031753AbWLGG5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 01:57:20 -0500
To: davem@davemloft.net, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Identify Serdes devices more clearly.

Change the message to more clearly identify Serdes devices.

Update version to 3.70.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 61e9533..a71707e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -68,8 +68,8 @@
 
 #define DRV_MODULE_NAME		"tg3"
 #define PFX DRV_MODULE_NAME	": "
-#define DRV_MODULE_VERSION	"3.69"
-#define DRV_MODULE_RELDATE	"November 15, 2006"
+#define DRV_MODULE_VERSION	"3.70"
+#define DRV_MODULE_RELDATE	"December 1, 2006"
 
 #define TG3_DEF_MAC_MODE	0
 #define TG3_DEF_RX_MODE		0
@@ -11932,13 +11932,15 @@ static int __devinit tg3_init_one(struct
 
 	pci_set_drvdata(pdev, dev);
 
-	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x PHY(%s)] (%s) %sBaseT Ethernet ",
+	printk(KERN_INFO "%s: Tigon3 [partno(%s) rev %04x PHY(%s)] (%s) %s Ethernet ",
 	       dev->name,
 	       tp->board_part_number,
 	       tp->pci_chip_rev_id,
 	       tg3_phy_string(tp),
 	       tg3_bus_string(tp, str),
-	       (tp->tg3_flags & TG3_FLAG_10_100_ONLY) ? "10/100" : "10/100/1000");
+	       ((tp->tg3_flags & TG3_FLAG_10_100_ONLY) ? "10/100Base-TX" :
+		((tp->tg3_flags2 & TG3_FLG2_ANY_SERDES) ? "1000Base-SX" :
+		 "10/100/1000Base-T")));
 
 	for (i = 0; i < 6; i++)
 		printk("%2.2x%c", dev->dev_addr[i],


