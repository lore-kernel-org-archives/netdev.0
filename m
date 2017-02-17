From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v2 08/12] net: ethernet: aquantia: Null pointer check for aq_nic_ndev_alloc.
Date: Sat, 18 Feb 2017 00:07:30 +0300
Message-ID: <c6fb341d5eee85c602fa35b760903bf7505f704e.1487365317.git.pavel.belous@aquantia.com>
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
Received: from mail-sn1nam01on0062.outbound.protection.outlook.com ([104.47.32.62]:48096
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S935088AbdBQVJV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 17 Feb 2017 16:09:21 -0500
In-Reply-To: <cover.1487365317.git.pavel.belous@aquantia.com>
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
