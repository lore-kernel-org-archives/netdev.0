From: Chaithrika U S <chaithrika@ti.com>
Subject: [PATCH] net-next-2.6 : TI DaVinci EMAC: Remove print_mac, DECLARE_MAC_BUF
Date: Tue,  2 Jun 2009 07:14:41 -0400
Message-ID: <1243941281-23046-1-git-send-email-chaithrika@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	Chaithrika U S <chaithrika@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:41594 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758690AbZFBLwf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 07:52:35 -0400
Received: from dflp53.itg.ti.com ([128.247.5.6])
	by devils.ext.ti.com (8.13.7/8.13.7) with ESMTP id n52BqUl7023751
	for <netdev@vger.kernel.org>; Tue, 2 Jun 2009 06:52:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use printk format specifier for MAC address.
Remove DECALRE_MAC_BUF and print_mac() usage in the driver.

Signed-off-by: Chaithrika U S <chaithrika@ti.com>
---
 drivers/net/davinci_emac.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index cf689a0..0e9b9f9 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1819,7 +1819,6 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
 	struct emac_rxch *rxch = priv->rxch[EMAC_DEF_RX_CH];
 	struct device *emac_dev = &priv->ndev->dev;
 	struct sockaddr *sa = addr;
-	DECLARE_MAC_BUF(mac);
 
 	/* Store mac addr in priv and rx channel and set it in EMAC hw */
 	memcpy(priv->mac_addr, sa->sa_data, ndev->addr_len);
@@ -1828,8 +1827,8 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
 	emac_setmac(priv, EMAC_DEF_RX_CH, rxch->mac_addr);
 
 	if (netif_msg_drv(priv))
-		dev_notice(emac_dev, "DaVinci EMAC: emac_dev_setmac_addr %s\n",
-			   print_mac(mac, priv->mac_addr));
+		dev_notice(emac_dev, "DaVinci EMAC: emac_dev_setmac_addr %pM\n",
+					priv->mac_addr);
 
 	return 0;
 }
@@ -2683,11 +2682,10 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	ndev->irq = res->start;
 
 	if (!is_valid_ether_addr(priv->mac_addr)) {
-		DECLARE_MAC_BUF(buf);
 		/* Use random MAC if none passed */
 		random_ether_addr(priv->mac_addr);
-		printk(KERN_WARNING "%s: using random MAC addr: %s\n",
-			__func__, print_mac(buf, priv->mac_addr));
+		printk(KERN_WARNING "%s: using random MAC addr: %pM\n",
+				__func__, priv->mac_addr);
 	}
 
 	ndev->netdev_ops = &emac_netdev_ops;
-- 
1.5.6

