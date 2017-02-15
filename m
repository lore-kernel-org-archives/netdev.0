From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next 03/13] net: ethernet: aquantia: Removed unnecessary comparsion "old_mtu == new_mtu".
Date: Wed, 15 Feb 2017 23:01:11 +0300
Message-ID: <a1cf5e938fa5997041c56cf898fadd830eb488f9.1487187192.git.pavel.belous@aquantia.com>
References: <cover.1487187192.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0063.outbound.protection.outlook.com ([104.47.40.63]:44304
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751578AbdBOUDX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:03:23 -0500
In-Reply-To: <cover.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

This check is not needed. Function aq_ndev_change_mtu wont be called
if mtu has not changed.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_main.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_main.c b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
index c17c70a..e5539c8 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_main.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_main.c
@@ -102,17 +102,15 @@ static int aq_ndev_change_mtu(struct net_device *ndev, int new_mtu)
 	struct aq_nic_s *aq_nic = netdev_priv(ndev);
 	int err = 0;
 
-	if (new_mtu == ndev->mtu) {
-		err = 0;
-		goto err_exit;
-	}
 	if (new_mtu < 68) {
 		err = -EINVAL;
 		goto err_exit;
 	}
+
 	err = aq_nic_set_mtu(aq_nic, new_mtu + ETH_HLEN);
 	if (err < 0)
 		goto err_exit;
+
 	ndev->mtu = new_mtu;
 
 	if (netif_running(ndev)) {
-- 
2.7.4
