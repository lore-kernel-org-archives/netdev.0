From: Eugene Konev <ejka@imfi.kspu.ru>
Subject: [PATCH 1/3] cpmac: use print_mac() instead of MAC_FMT
Date: Wed, 24 Oct 2007 10:42:01 +0800
Message-ID: <1193193723-12691-2-git-send-email-ejka@imfi.kspu.ru>
References: <1193193723-12691-1-git-send-email-ejka@imfi.kspu.ru>
Cc: Matteo Croce <technoboy85@gmail.com>, netdev@vger.kernel.org,
	Eugene Konev <ejka@imfi.kspu.ru>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 117.19.65.80.ip.morning.ru ([80.65.19.117]:54703 "EHLO
	mail.imfi.kspu.ru" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753859AbXJXDBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2007 23:01:12 -0400
In-Reply-To: <1193193723-12691-1-git-send-email-ejka@imfi.kspu.ru>
Message-Id: <5070e5ddd7ae0681b14e712980d830225a2103aa.1193191283.git.ejka@imfi.kspu.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch to using DECLARE_MAC_BUF/print_mac() added by commit
0795af5729b18218767fab27c44b1384f72dc9ad [NET]: Introduce and use print_mac()
and DECLARE_MAC_BUF().


Signed-off-by: Eugene Konev <ejka@imfi.kspu.ru>
---
 drivers/net/cpmac.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index 57541d2..0598d4d 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -53,12 +53,6 @@ MODULE_PARM_DESC(debug_level, "Number of NETIF_MSG bits to enable");
 MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
 
 #define CPMAC_VERSION "0.5.0"
-/* stolen from net/ieee80211.h */
-#ifndef MAC_FMT
-#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
-#define MAC_ARG(x) ((u8*)(x))[0], ((u8*)(x))[1], ((u8*)(x))[2], \
-		   ((u8*)(x))[3], ((u8*)(x))[4], ((u8*)(x))[5]
-#endif
 /* frame size + 802.1q tag */
 #define CPMAC_SKB_SIZE		(ETH_FRAME_LEN + 4)
 #define CPMAC_QUEUES	8
@@ -1006,6 +1000,7 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 	struct cpmac_priv *priv;
 	struct net_device *dev;
 	struct plat_cpmac_data *pdata;
+	DECLARE_MAC_BUF(mac);
 
 	pdata = pdev->dev.platform_data;
 
@@ -1077,9 +1072,9 @@ static int __devinit cpmac_probe(struct platform_device *pdev)
 
 	if (netif_msg_probe(priv)) {
 		printk(KERN_INFO
-		       "cpmac: device %s (regs: %p, irq: %d, phy: %s, mac: "
-		       MAC_FMT ")\n", dev->name, (void *)mem->start, dev->irq,
-		       priv->phy_name, MAC_ARG(dev->dev_addr));
+		       "cpmac: device %s (regs: %p, irq: %d, phy: %s, "
+		       "mac: %s)\n", dev->name, (void *)mem->start, dev->irq,
+		       priv->phy_name, print_mac(mac, dev->dev_addr));
 	}
 	return 0;
 
-- 
1.5.3.4

