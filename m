From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next 08/13] net: ethernet: aquantia: Null pointer check for aq_nic_ndev_alloc.
Date: Wed, 15 Feb 2017 23:01:16 +0300
Message-ID: <34586a7fe70a07e8713b20e82a2191a3530b8ff1.1487187192.git.pavel.belous@aquantia.com>
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
        id S1751860AbdBOUDj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 15 Feb 2017 15:03:39 -0500
In-Reply-To: <cover.1487187192.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

We should check for a null pointer for aq_nic_ndev_alloc
instead netdev_priv.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 4cf633c..e50fba2 100644
--- a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
@@ -202,12 +202,13 @@ struct aq_nic_s *aq_nic_alloc_cold(const struct net_device_ops *ndev_ops,
 	int err = 0;
 
 	ndev = aq_nic_ndev_alloc();
-	self = netdev_priv(ndev);
-	if (!self) {
-		err = -EINVAL;
+	if (!ndev) {
+		err = -ENOMEM;
 		goto err_exit;
 	}
 
+	self = netdev_priv(ndev);
+
 	ndev->netdev_ops = ndev_ops;
 	ndev->ethtool_ops = et_ops;
 
-- 
2.7.4
