From: Tobias Klauser <tklauser@distanz.ch>
Subject: [PATCH] arc_emac: Remove unused pointer to net_device from arc_emac_priv
Date: Wed,  9 Jul 2014 11:07:56 +0200
Message-ID: <1404896876-29315-1-git-send-email-tklauser@distanz.ch>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.zhinst.com ([212.126.164.98]:39108 "EHLO mail.zhinst.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753660AbaGIJIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 05:08:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The pointer to the struct net_device in the private data is only
assigned but never used, so delete it.

Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
---
 drivers/net/ethernet/arc/emac.h      | 2 --
 drivers/net/ethernet/arc/emac_main.c | 1 -
 2 files changed, 3 deletions(-)

diff --git a/drivers/net/ethernet/arc/emac.h b/drivers/net/ethernet/arc/emac.h
index 8e7c1a1..36cc9bd 100644
--- a/drivers/net/ethernet/arc/emac.h
+++ b/drivers/net/ethernet/arc/emac.h
@@ -105,7 +105,6 @@ struct buffer_state {
 /**
  * struct arc_emac_priv - Storage of EMAC's private information.
  * @dev:	Pointer to the current device.
- * @ndev:	Pointer to the current network device.
  * @phy_dev:	Pointer to attached PHY device.
  * @bus:	Pointer to the current MII bus.
  * @regs:	Base address of EMAC memory-mapped control registers.
@@ -126,7 +125,6 @@ struct buffer_state {
 struct arc_emac_priv {
 	/* Devices */
 	struct device *dev;
-	struct net_device *ndev;
 	struct phy_device *phy_dev;
 	struct mii_bus *bus;
 
diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index 6cfcd38..fe5cfea 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -720,7 +720,6 @@ static int arc_emac_probe(struct platform_device *pdev)
 
 	priv = netdev_priv(ndev);
 	priv->dev = &pdev->dev;
-	priv->ndev = ndev;
 
 	priv->regs = devm_ioremap_resource(&pdev->dev, &res_regs);
 	if (IS_ERR(priv->regs)) {
-- 
2.0.1
