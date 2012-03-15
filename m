From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 07/34] via-velocity: stop using net_device.{base_addr, irq}.
Date: Thu, 15 Mar 2012 14:57:04 +0100
Message-ID: <e7ff4b8be11667aa547995e0198700a1669eeae4.1331814082.git.romieu@fr.zoreil.com>
References: <cover.1331814082.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	David Lv <DavidLv@viatech.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:51837 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752784Ab2CON7o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 09:59:44 -0400
In-Reply-To: <cover.1331814082.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: David Lv <DavidLv@viatech.com.cn>
---
 drivers/net/ethernet/via/via-velocity.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index 8a5d7c1..ea3e0a2 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -2488,8 +2488,8 @@ static int velocity_close(struct net_device *dev)
 
 	if (vptr->flags & VELOCITY_FLAGS_WOL_ENABLED)
 		velocity_get_ip(vptr);
-	if (dev->irq != 0)
-		free_irq(dev->irq, dev);
+
+	free_irq(vptr->pdev->irq, dev);
 
 	velocity_free_rings(vptr);
 
@@ -2755,8 +2755,6 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 	if (ret < 0)
 		goto err_free_dev;
 
-	dev->irq = pdev->irq;
-
 	ret = velocity_get_pci_info(vptr, pdev);
 	if (ret < 0) {
 		/* error message already printed */
@@ -2779,8 +2777,6 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 
 	mac_wol_reset(regs);
 
-	dev->base_addr = vptr->ioaddr;
-
 	for (i = 0; i < 6; i++)
 		dev->dev_addr[i] = readb(&regs->PAR[i]);
 
@@ -2806,7 +2802,6 @@ static int __devinit velocity_found1(struct pci_dev *pdev, const struct pci_devi
 
 	vptr->phy_id = MII_GET_PHY_ID(vptr->mac_regs);
 
-	dev->irq = pdev->irq;
 	dev->netdev_ops = &velocity_netdev_ops;
 	dev->ethtool_ops = &velocity_ethtool_ops;
 	netif_napi_add(dev, &vptr->napi, velocity_poll, VELOCITY_NAPI_WEIGHT);
-- 
1.7.7.6
