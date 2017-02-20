From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v4 05/12] net: ethernet: aquantia: Superfluous initialization of "err".
Date: Mon, 20 Feb 2017 22:36:43 +0300
Message-ID: <1881f5e1f5f524a758f46d5d084eedf9c90f03d4.1487618263.git.pavel.belous@aquantia.com>
References: <cover.1487618263.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0068.outbound.protection.outlook.com ([104.47.38.68]:52795
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751403AbdBTTh5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 14:37:57 -0500
In-Reply-To: <cover.1487618263.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

Fixed superfluous initialization of err.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/aquantia/atlantic/aq_main.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
index 91c66f5..dad6362 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
@@ -87,14 +87,8 @@ static int aq_ndev_close(struct net_device *ndev)
 static int aq_ndev_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	struct aq_nic_s *aq_nic = netdev_priv(ndev);
-	int err = 0;
-
-	err = aq_nic_xmit(aq_nic, skb);
-	if (err < 0)
-		goto err_exit;
 
-err_exit:
-	return err;
+	return aq_nic_xmit(aq_nic, skb);
 }
 
 static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
-- 
2.7.4
