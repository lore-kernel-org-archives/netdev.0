From: Pavel Belous <Pavel.Belous@aquantia.com>
Subject: [PATCH net-next v3 08/12] net: ethernet: aquantia: Null pointer check for aq_nic_ndev_alloc.
Date: Mon, 20 Feb 2017 14:41:50 +0300
Message-ID: <9dfb70bb6d3f7930a48f6392e05eff6892feb5f9.1487590641.git.pavel.belous@aquantia.com>
References: <cover.1487590641.git.pavel.belous@aquantia.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexey Andriyanov <Alexey.Andriyanov@aquantia.com>,
        Lino Sanfilippo <LinoSanfilippo@gmx.de>,
        Pavel Belous <pavel.belous@aquantia.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0086.outbound.protection.outlook.com ([104.47.42.86]:47808
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752854AbdBTLnE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 20 Feb 2017 06:43:04 -0500
In-Reply-To: <cover.1487590641.git.pavel.belous@aquantia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Belous <pavel.belous@aquantia.com>

We should check for a null pointer for aq_nic_ndev_alloc
instead netdev_priv.

Signed-off-by: Pavel Belous <pavel.belous@aquantia.com>
Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>
---
 drivers/net/ethernet/aquantia/atlantic/aq_nic.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_nic.c b/drivers/net/ethernet/aquantia/atlantic/aq_nic.c
index 019bcc7..a8a27c5 100644
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
