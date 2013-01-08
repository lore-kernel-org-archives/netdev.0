From: Fabio Estevam <festevam@gmail.com>
Subject: [PATCH v3] net: fec: Remove 'inline' declarations
Date: Tue,  8 Jan 2013 01:42:56 -0200
Message-ID: <1357616576-25307-1-git-send-email-festevam@gmail.com>
Cc: shawn.guo@linaro.org, netdev@vger.kernel.org, joe@perches.com,
	Fabio Estevam <fabio.estevam@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f178.google.com ([209.85.213.178]:43142 "EHLO
	mail-ye0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab3AHDnM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 22:43:12 -0500
Received: by mail-ye0-f178.google.com with SMTP id j12so1337766yeg.37
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 19:43:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>

Fix the following warning when building with W=1 option:

drivers/net/ethernet/freescale/fec.c:810:1: warning: '__inline__' is not at beginning of declaration [-Wold-style-declaration]

The inline declaration is pointless in this function, so just remove it.

While at it, also remove the other 'inline' declarations.

Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
---
Changses since v2:
- Update Subject
- Remove other inline
Changes since v1:
- Remove the 'inline'
 drivers/net/ethernet/freescale/fec.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec.c b/drivers/net/ethernet/freescale/fec.c
index a379319..16a1640d 100644
--- a/drivers/net/ethernet/freescale/fec.c
+++ b/drivers/net/ethernet/freescale/fec.c
@@ -807,7 +807,7 @@ fec_enet_interrupt(int irq, void *dev_id)
 
 
 /* ------------------------------------------------------------------------- */
-static void __inline__ fec_get_mac(struct net_device *ndev)
+static void fec_get_mac(struct net_device *ndev)
 {
 	struct fec_enet_private *fep = netdev_priv(ndev);
 	struct fec_platform_data *pdata = fep->pdev->dev.platform_data;
@@ -1562,12 +1562,12 @@ static void fec_reset_phy(struct platform_device *pdev)
 	gpio_set_value(phy_reset, 1);
 }
 #else /* CONFIG_OF */
-static inline int fec_get_phy_mode_dt(struct platform_device *pdev)
+static int fec_get_phy_mode_dt(struct platform_device *pdev)
 {
 	return -ENODEV;
 }
 
-static inline void fec_reset_phy(struct platform_device *pdev)
+static void fec_reset_phy(struct platform_device *pdev)
 {
 	/*
 	 * In case of platform probe, the reset has been done
-- 
1.7.9.5
