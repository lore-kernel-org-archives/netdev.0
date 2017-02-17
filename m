From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v2 03/12] net: ethernet: aquantia: Removed unnecessary comparsion "old_mtu == new_mtu".
Date: Sat, 18 Feb 2017 00:07:25 +0300
Message-ID: <6b965301a08041d2a8d8537a25e8a0642fa6d669.1487365317.git.pavel.belous@aquantia.com>
References: <cover.1487365317.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0077.outbound.protection.outlook.com ([104.47.32.77]:52345
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935065AbdBQVJK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 16:09:10 -0500
In-Reply-To: <cover.1487365317.git.pavel.belous@aquantia.com>
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
