From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 04/11] davinci_emac: pass ioctls through to phy device.
Date: Fri, 10 Jun 2011 17:24:50 +0200
Message-ID: <08e978ffe182f3a71a50f3b20f1c314c648965b1.1307719258.git.richard.cochran@omicron.at>
References: <cover.1307719258.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>, Anant Gole <anantgole@ti.com>,
	Kevin Hilman <khilman@deeprootsystems.com>,
	Chaithrika U S <chaithrika@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:50851 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757789Ab1FJPZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2011 11:25:12 -0400
Received: by mail-bw0-f46.google.com with SMTP id 15so2274042bwz.19
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2011 08:25:12 -0700 (PDT)
In-Reply-To: <cover.1307719258.git.richard.cochran@omicron.at>
In-Reply-To: <cover.1307719258.git.richard.cochran@omicron.at>
References: <cover.1307719258.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The DaVinci EMAC driver does not implement any ioctls, but still it can
pass them through to the phy device. This makes it possible for a phy
to offer PHC capabilities.

Cc: Anant Gole <anantgole@ti.com>
Cc: Kevin Hilman <khilman@deeprootsystems.com>
Cc: Chaithrika U S <chaithrika@ti.com>
Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
---
 drivers/net/davinci_emac.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 29a4f06..efa2901 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -1489,14 +1489,14 @@ static void emac_adjust_link(struct net_device *ndev)
  */
 static int emac_devioctl(struct net_device *ndev, struct ifreq *ifrq, int cmd)
 {
-	dev_warn(&ndev->dev, "DaVinci EMAC: ioctl not supported\n");
+	struct emac_priv *priv = netdev_priv(ndev);
 
 	if (!(netif_running(ndev)))
 		return -EINVAL;
 
 	/* TODO: Add phy read and write and private statistics get feature */
 
-	return -EOPNOTSUPP;
+	return phy_mii_ioctl(priv->phydev, ifrq, cmd);
 }
 
 static int match_first_device(struct device *dev, void *data)
-- 
1.7.0.4

