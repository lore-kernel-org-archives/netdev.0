From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] net: ethernet: mediatek: mark symbols static where possible
Date: Fri, 30 Sep 2016 15:48:50 +0800
Message-ID: <1475221730-18773-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: nbd@openwrt.org, blogic@openwrt.org, matthias.bgg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35583 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbcI3HtM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 03:49:12 -0400
Received: by mail-pf0-f174.google.com with SMTP id s13so37705326pfd.2
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 00:49:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We get 2 warnings when building kernel with W=1:
drivers/net/ethernet/mediatek/mtk_eth_soc.c:2041:5: warning: no previous prototype for 'mtk_get_link_ksettings' [-Wmissing-prototypes]
drivers/net/ethernet/mediatek/mtk_eth_soc.c:2052:5: warning: no previous prototype for 'mtk_set_link_ksettings' [-Wmissing-prototypes]

In fact, these functions are only used in the file in which they are
declared and don't need a declaration, but can be made static.
So this patch marks these functions with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index ddf20a0..ad4ab97 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -2038,8 +2038,8 @@ static int mtk_cleanup(struct mtk_eth *eth)
 	return 0;
 }
 
-int mtk_get_link_ksettings(struct net_device *ndev,
-			   struct ethtool_link_ksettings *cmd)
+static int mtk_get_link_ksettings(struct net_device *ndev,
+				  struct ethtool_link_ksettings *cmd)
 {
 	struct mtk_mac *mac = netdev_priv(ndev);
 
@@ -2049,8 +2049,8 @@ int mtk_get_link_ksettings(struct net_device *ndev,
 	return phy_ethtool_ksettings_get(ndev->phydev, cmd);
 }
 
-int mtk_set_link_ksettings(struct net_device *ndev,
-			   const struct ethtool_link_ksettings *cmd)
+static int mtk_set_link_ksettings(struct net_device *ndev,
+				  const struct ethtool_link_ksettings *cmd)
 {
 	struct mtk_mac *mac = netdev_priv(ndev);
 
-- 
2.7.4
