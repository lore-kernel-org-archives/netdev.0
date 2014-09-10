From: Romain Perier <romain.perier@gmail.com>
Subject: [PATCH v1] net: ethernet: arc: Don't free Rockchip resources before disconnect from phy
Date: Wed, 10 Sep 2014 07:51:13 +0000
Message-ID: <1410335473-23573-1-git-send-email-romain.perier@gmail.com>
Cc: linux-rockchip@lists.infradead.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: heiko@sntech.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:64687 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751993AbaIJHsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 03:48:52 -0400
Received: by mail-wi0-f171.google.com with SMTP id hi2so5743095wib.4
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 00:48:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Free resources before being disconnected from phy and calling core driver is
wrong and should not happen. It avoids a delay of 4-5s caused by the timeout of
phy_disconnect().

Signed-off-by: Romain Perier <romain.perier@gmail.com>
---
 drivers/net/ethernet/arc/emac_rockchip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/arc/emac_rockchip.c b/drivers/net/ethernet/arc/emac_rockchip.c
index 51d0585..c31c740 100644
--- a/drivers/net/ethernet/arc/emac_rockchip.c
+++ b/drivers/net/ethernet/arc/emac_rockchip.c
@@ -202,12 +202,13 @@ static int emac_rockchip_remove(struct platform_device *pdev)
 	struct rockchip_priv_data *priv = netdev_priv(ndev);
 	int err;
 
+	err = arc_emac_remove(ndev);
+
 	clk_disable_unprepare(priv->refclk);
 
 	if (priv->regulator)
 		regulator_disable(priv->regulator);
 
-	err = arc_emac_remove(ndev);
 	free_netdev(ndev);
 	return err;
 }
-- 
1.9.1
