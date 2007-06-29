From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 19/21] r8169: display some extra debug information during startup
Date: Fri, 29 Jun 2007 22:28:41 +0200
Message-ID: <20070629202841.GU3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32790 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753425AbXF2UcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:32:22 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It does not cost much and it will ease the identification of (so far)
unknown devices.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index f66ee3b..dc8f369 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1646,15 +1646,17 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_drvdata(pdev, dev);
 
 	if (netif_msg_probe(tp)) {
+		u32 xid = RTL_R32(TxConfig) & 0x7cf0f8ff;
+
 		printk(KERN_INFO "%s: %s at 0x%lx, "
 		       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
-		       "IRQ %d\n",
+		       "XID %08x IRQ %d\n",
 		       dev->name,
 		       rtl_chip_info[tp->chipset].name,
 		       dev->base_addr,
 		       dev->dev_addr[0], dev->dev_addr[1],
 		       dev->dev_addr[2], dev->dev_addr[3],
-		       dev->dev_addr[4], dev->dev_addr[5], dev->irq);
+		       dev->dev_addr[4], dev->dev_addr[5], xid, dev->irq);
 	}
 
 	rtl8169_init_phy(dev, tp);
-- 
1.4.4.2

